import { NextRequest, NextResponse } from "next/server";
import { readFileSync, existsSync } from "fs";
import path from "path";

export async function GET(req: NextRequest, { params }: { params: { file: string[] } }) {
  try {
    const filename = params.file.join("/");
    
    // Güvenlik: Dizin atlamayı engelle
    if (filename.includes("..") || filename.includes("\0")) {
      return new NextResponse("Unauthorized", { status: 401 });
    }

    const cwd = process.cwd();
    let filePath = path.join(cwd, "public", "uploads", filename);
    
    // Standalone ortamındaysak ve dosya lokal standalone içinde yoksa root dizinindeki yedeğe bak
    const isStandalone = cwd.includes(".next" + path.sep + "standalone") || cwd.endsWith("standalone");
    if (!existsSync(filePath) && isStandalone) {
       const rootPath = path.join(cwd, "..", "..", "public", "uploads", filename);
       if (existsSync(rootPath)) {
          filePath = rootPath;
       }
    }

    if (!existsSync(filePath)) {
      return new NextResponse("File not found dynamically", { status: 404 });
    }

    const fileBuffer = readFileSync(filePath);
    
    let contentType = "application/octet-stream";
    if (filename.endsWith(".pdf")) contentType = "application/pdf";
    else if (filename.match(/\.(jpeg|jpg)$/i)) contentType = "image/jpeg";
    else if (filename.endsWith(".png")) contentType = "image/png";

    return new NextResponse(fileBuffer, {
      headers: {
        "Content-Type": contentType,
        "Cache-Control": "public, max-age=31536000, immutable",
      },
    });
  } catch (error) {
    console.error("Uploads API Error:", error);
    return new NextResponse("Internal Server Error", { status: 500 });
  }
}
