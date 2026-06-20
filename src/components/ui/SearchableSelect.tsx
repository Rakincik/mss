"use client";

import React, { useState, useRef, useEffect } from "react";
import { ChevronDown, Search, X } from "lucide-react";

interface Option {
  value: string;
  label: string;
}

interface SearchableSelectProps {
  name?: string;
  options: Option[];
  value?: string;
  defaultValue?: string;
  placeholder?: string;
  hideSearch?: boolean;
  onChange?: (val: string) => void;
}

export default function SearchableSelect({ name, options, value, defaultValue = "", placeholder = "Seçiniz...", hideSearch = false, onChange }: SearchableSelectProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [internalValue, setInternalValue] = useState(defaultValue);
  
  const containerRef = useRef<HTMLDivElement>(null);

  const selectedValue = value !== undefined ? value : internalValue;

  useEffect(() => {
    if (value === undefined) {
       setInternalValue(defaultValue);
    }
  }, [defaultValue, value]);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleSelect = (val: string) => {
    if (value === undefined) setInternalValue(val);
    setSearchTerm("");
    setIsOpen(false);
    if (onChange) onChange(val);
  };

  const handleClear = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (value === undefined) setInternalValue("");
    setSearchTerm("");
    if (onChange) onChange("");
  };

  const filteredOptions = options.filter(opt => 
    opt.label.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const selectedOption = options.find(opt => opt.value === selectedValue);

  return (
    <div className="relative w-full" ref={containerRef}>
      {name && <input type="hidden" name={name} value={selectedValue} />}
      
      {/* Trigger Button */}
      <div 
        className="w-full flex items-center justify-between text-sm text-slate-700 bg-slate-50 border border-slate-200 px-4 py-2.5 rounded-xl mb-3 outline-none focus-within:border-emerald-500 cursor-pointer transition-colors"
        onClick={() => setIsOpen(!isOpen)}
      >
        <span className="truncate pr-4 select-none font-medium">
          {selectedOption ? selectedOption.label : placeholder}
        </span>
        <div className="flex items-center gap-1 shrink-0 text-slate-400">
          {selectedValue && (
             <button 
                type="button" 
                className="p-1 hover:bg-slate-200 rounded-md transition-colors"
                onClick={handleClear}
             >
                <X className="w-3 h-3" />
             </button>
          )}
          <ChevronDown className={`w-4 h-4 transition-transform ${isOpen ? 'rotate-180' : ''}`} />
        </div>
      </div>

      {/* Dropdown List */}
      {isOpen && (
        <div className="absolute z-50 w-full mt-[-8px] bg-white border border-slate-200 rounded-xl shadow-xl max-h-60 flex flex-col overflow-hidden animate-in fade-in slide-in-from-top-2">
          {!hideSearch && (
            <div className="p-2 border-b border-slate-100 shrink-0 relative">
               <Search className="w-4 h-4 absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
               <input 
                 type="text" 
                 className="w-full pl-8 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm outline-none focus:border-emerald-500 transition-colors"
                 placeholder="Ara..."
                 value={searchTerm}
                 onChange={(e) => setSearchTerm(e.target.value)}
                 onClick={(e) => e.stopPropagation()}
                 autoFocus
               />
            </div>
          )}
          <div className="overflow-y-auto custom-scrollbar p-1">
             <div 
                className={`px-3 py-2 text-sm rounded-lg cursor-pointer transition-colors ${selectedValue === "" ? 'bg-emerald-50 text-emerald-700 font-bold' : 'text-slate-600 hover:bg-slate-50'}`}
                onClick={() => handleSelect("")}
             >
                {placeholder}
             </div>
             {filteredOptions.length === 0 ? (
                <div className="px-3 py-4 text-sm text-center text-slate-400">Sonuç bulunamadı</div>
             ) : (
                filteredOptions.map((opt) => (
                  <div 
                    key={opt.value}
                    className={`px-3 py-2 text-sm rounded-lg cursor-pointer transition-colors truncate ${selectedValue === opt.value ? 'bg-emerald-50 text-emerald-700 font-bold' : 'text-slate-600 hover:bg-slate-50'}`}
                    onClick={() => handleSelect(opt.value)}
                    title={opt.label}
                  >
                    {opt.label}
                  </div>
                ))
             )}
          </div>
        </div>
      )}
    </div>
  );
}
