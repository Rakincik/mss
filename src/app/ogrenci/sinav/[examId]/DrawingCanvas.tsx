"use client";

import React, { useRef, useEffect, useState, useCallback, useImperativeHandle } from "react";

export type DrawingMode = "pan" | "pen" | "highlighter" | "eraser";
export type Point = { x: number; y: number };
export type Stroke = {
  points: Point[];
  color: string;
  thickness: number;
  isHighlighter: boolean;
};

interface DrawingCanvasProps {
  width: number;
  height: number;
  scale: number;
  mode: DrawingMode;
  color: string;
  thickness: number;
  strokes: Stroke[];
  onStrokeAdd: (stroke: Stroke) => void;
  onStrokesChange: (strokes: Stroke[]) => void;
}

export const DrawingCanvas = React.forwardRef<any, DrawingCanvasProps>(({
  width,
  height,
  scale,
  mode,
  color,
  thickness,
  strokes,
  onStrokeAdd,
  onStrokesChange
}, ref) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [currentPoints, setCurrentPoints] = useState<Point[]>([]);

  // Function to redraw everything
  const drawAll = useCallback(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    ctx.clearRect(0, 0, width, height);
    ctx.lineCap = "round";
    ctx.lineJoin = "round";

    // Draw saved strokes
    strokes.forEach((stroke) => {
      if (stroke.points.length === 0) return;
      ctx.beginPath();
      const p0 = stroke.points[0];
      ctx.moveTo(p0.x * scale, p0.y * scale);
      
      stroke.points.forEach((p) => {
        ctx.lineTo(p.x * scale, p.y * scale);
      });

      ctx.strokeStyle = stroke.color;
      ctx.lineWidth = stroke.thickness * scale;
      ctx.globalAlpha = stroke.isHighlighter ? 0.3 : 1.0;
      if (stroke.isHighlighter) {
        ctx.globalCompositeOperation = "multiply";
      } else {
        ctx.globalCompositeOperation = "source-over";
      }
      ctx.stroke();
    });
    
    // Draw current line
    if (isDrawing && currentPoints.length > 0) {
      ctx.beginPath();
      const p0 = currentPoints[0];
      ctx.moveTo(p0.x * scale, p0.y * scale);
      currentPoints.forEach((p) => ctx.lineTo(p.x * scale, p.y * scale));
      ctx.strokeStyle = color;
      ctx.lineWidth = thickness * scale;
      ctx.globalAlpha = mode === "highlighter" ? 0.3 : 1.0;
      if (mode === "highlighter") ctx.globalCompositeOperation = "multiply";
      else ctx.globalCompositeOperation = "source-over";
      ctx.stroke();
    }
  }, [width, height, scale, strokes, isDrawing, currentPoints, color, thickness, mode]);

  useEffect(() => {
    drawAll();
  }, [drawAll]);

  useImperativeHandle(ref, () => ({
    clearAll: () => {
      onStrokesChange([]);
    }
  }));

  const getCoordinates = (e: React.PointerEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return { x: 0, y: 0 };
    const rect = canvas.getBoundingClientRect();
    // Normalize coordinates back to scale = 1.0
    return {
      x: (e.clientX - rect.left) / scale,
      y: (e.clientY - rect.top) / scale
    };
  };

  const handlePointerDown = (e: React.PointerEvent<HTMLCanvasElement>) => {
    if (mode === "pan") return;
    
    e.preventDefault();
    canvasRef.current?.setPointerCapture(e.pointerId);

    const coords = getCoordinates(e);

    if (mode === "eraser") {
      eraseStrokeAt(coords);
      return;
    }

    setIsDrawing(true);
    setCurrentPoints([coords]);
  };

  const handlePointerMove = (e: React.PointerEvent<HTMLCanvasElement>) => {
    if (mode === "pan" || !isDrawing) return;
    
    const coords = getCoordinates(e);

    if (mode === "eraser") {
      if (e.buttons > 0) eraseStrokeAt(coords);
      return;
    }

    setCurrentPoints(prev => [...prev, coords]);
  };

  const handlePointerUp = (e: React.PointerEvent<HTMLCanvasElement>) => {
    if (mode === "pan") return;
    canvasRef.current?.releasePointerCapture(e.pointerId);

    if (isDrawing && currentPoints.length > 0) {
      onStrokeAdd({
        points: currentPoints,
        color,
        thickness,
        isHighlighter: mode === "highlighter"
      });
    }
    
    setIsDrawing(false);
    setCurrentPoints([]);
  };

  // Erase logic: check if the pointer is near any line segments
  const eraseStrokeAt = (point: Point) => {
    const ERASE_RADIUS = 15; // 15px radius for erasing logic at scale 1
    const newStrokes = strokes.filter(stroke => {
      // Return true if we SHOULD KEEP the stroke
      for (const p of stroke.points) {
        const dx = p.x - point.x;
        const dy = p.y - point.y;
        if (dx * dx + dy * dy < ERASE_RADIUS * ERASE_RADIUS) {
          return false; // Point is inside erase radius, remove this stroke
        }
      }
      return true;
    });

    if (newStrokes.length !== strokes.length) {
      onStrokesChange(newStrokes);
    }
  };

  return (
    <canvas
      ref={canvasRef}
      width={width}
      height={height}
      style={{
        width: `${width}px`,
        height: `${height}px`,
        position: "absolute",
        top: 0,
        left: 0,
        pointerEvents: mode === "pan" ? "none" : "auto",
        touchAction: "none", // Prevent scrolling when drawing
        zIndex: 50
      }}
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      onPointerCancel={handlePointerUp}
      onPointerOut={handlePointerUp}
    />
  );
});

DrawingCanvas.displayName = "DrawingCanvas";
