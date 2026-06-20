"use client";

import dynamic from "next/dynamic";

// react-pdf kütüphanesinin DOMMatrix hatasını önlemek için SSR'ı kapatıyoruz.
const SolutionInterface = dynamic(() => import("./SolutionInterface"), { ssr: false });

export default SolutionInterface;
