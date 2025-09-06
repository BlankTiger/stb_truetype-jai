//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



STBTT_MACSTYLE_DONTCARE :: 0;
STBTT_MACSTYLE_BOLD :: 1;
STBTT_MACSTYLE_ITALIC :: 2;
STBTT_MACSTYLE_UNDERSCORE :: 4;
STBTT_MACSTYLE_NONE :: 8;

// private structure
buf :: struct {
    data:   *u8;
    cursor: s32;
    size:   s32;
}

//////////////////////////////////////////////////////////////////////////////
//
// TEXTURE BAKING API
//
// If you use this API, you only have to call two functions ever.
//
bakedchar :: struct {
    x0:       u16; // coordinates of bbox in bitmap
    y0:       u16; // coordinates of bbox in bitmap
    x1:       u16; // coordinates of bbox in bitmap
    y1:       u16; // coordinates of bbox in bitmap
    xoff:     float;
    yoff:     float;
    xadvance: float;
}

BakeFontBitmap :: (data: *u8, offset: s32, pixel_height: float, pixels: *u8, pw: s32, ph: s32, first_char: s32, num_chars: s32, chardata: *bakedchar) -> s32 #foreign stb_truetype "stbtt_BakeFontBitmap";

// if return is positive, the first unused row of the bitmap
// if return is negative, returns the negative of the number of characters that fit
// if return is 0, no characters fit and no rows were used
// This uses a very crappy packing.
aligned_quad :: struct {
    x0: float; // top-left
    y0: float; // top-left
    s0: float; // top-left
    t0: float; // top-left
    x1: float; // bottom-right
    y1: float; // bottom-right
    s1: float; // bottom-right
    t1: float; // bottom-right
}

GetBakedQuad :: (chardata: *bakedchar, pw: s32, ph: s32, char_index: s32, xpos: *float, ypos: *float, q: *aligned_quad, opengl_fillrule: s32) -> void #foreign stb_truetype "stbtt_GetBakedQuad";

// Call GetBakedQuad with char_index = 'character - first_char', and it
// creates the quad you need to draw and advances the current position.
//
// The coordinate system used assumes y increases downwards.
//
// Characters will extend both above and below the current position;
// see discussion of "BASELINE" above.
//
// It's inefficient; you might want to c&p it and optimize it.
GetScaledFontVMetrics :: (fontdata: *u8, index: s32, size: float, ascent: *float, descent: *float, lineGap: *float) -> void #foreign stb_truetype "stbtt_GetScaledFontVMetrics";

//////////////////////////////////////////////////////////////////////////////
//
// NEW TEXTURE BAKING API
//
// This provides options for packing multiple fonts into one atlas, not
// perfectly but better than nothing.
packedchar :: struct {
    x0:       u16; // coordinates of bbox in bitmap
    y0:       u16; // coordinates of bbox in bitmap
    x1:       u16; // coordinates of bbox in bitmap
    y1:       u16; // coordinates of bbox in bitmap
    xoff:     float;
    yoff:     float;
    xadvance: float;
    xoff2:    float;
    yoff2:    float;
}

stbrp_rect :: struct {}

PackBegin :: (spc: *pack_context, pixels: *u8, width: s32, height: s32, stride_in_bytes: s32, padding: s32, alloc_context: *void) -> s32 #foreign stb_truetype "stbtt_PackBegin";

// Initializes a packing context stored in the passed-in stbtt_pack_context.
// Future calls using this context will pack characters into the bitmap passed
// in here: a 1-channel bitmap that is width * height. stride_in_bytes is
// the distance from one row to the next (or 0 to mean they are packed tightly
// together). "padding" is the amount of padding to leave between each
// character (normally you want '1' for bitmaps you'll use as textures with
// bilinear filtering).
//
// Returns 0 on failure, 1 on success.
PackEnd :: (spc: *pack_context) -> void #foreign stb_truetype "stbtt_PackEnd";

PackFontRange :: (spc: *pack_context, fontdata: *u8, font_index: s32, font_size: float, first_unicode_char_in_range: s32, num_chars_in_range: s32, chardata_for_range: *packedchar) -> s32 #foreign stb_truetype "stbtt_PackFontRange";

// Creates character bitmaps from the font_index'th font found in fontdata (use
// font_index=0 if you don't know what that is). It creates num_chars_in_range
// bitmaps for characters with unicode values starting at first_unicode_char_in_range
// and increasing. Data for how to render them is stored in chardata_for_range;
// pass these to stbtt_GetPackedQuad to get back renderable quads.
//
// font_size is the full height of the character from ascender to descender,
// as computed by stbtt_ScaleForPixelHeight. To use a point size as computed
// by stbtt_ScaleForMappingEmToPixels, wrap the point size in STBTT_POINT_SIZE()
// and pass that result as 'font_size':
//       ...,                  20 , ... // font max minus min y is 20 pixels tall
//       ..., STBTT_POINT_SIZE(20), ... // 'M' is 20 pixels tall
pack_range :: struct {
    font_size:                        float;
    first_unicode_codepoint_in_range: s32; // if non-zero, then the chars are continuous, and this is the first codepoint
    array_of_unicode_codepoints:      *s32; // if non-zero, then this is an array of unicode codepoints
    num_chars:                        s32;
    chardata_for_range:               *packedchar; // output
    h_oversample:                     u8; // don't set these, they're used internally
    v_oversample:                     u8; // don't set these, they're used internally
}

PackFontRanges :: (spc: *pack_context, fontdata: *u8, font_index: s32, ranges: *pack_range, num_ranges: s32) -> s32 #foreign stb_truetype "stbtt_PackFontRanges";

// Creates character bitmaps from multiple ranges of characters stored in
// ranges. This will usually create a better-packed bitmap than multiple
// calls to stbtt_PackFontRange. Note that you can call this multiple
// times within a single PackBegin/PackEnd.
PackSetOversampling :: (spc: *pack_context, h_oversample: u32, v_oversample: u32) -> void #foreign stb_truetype "stbtt_PackSetOversampling";

// Oversampling a font increases the quality by allowing higher-quality subpixel
// positioning, and is especially valuable at smaller text sizes.
//
// This function sets the amount of oversampling for all following calls to
// stbtt_PackFontRange(s) or stbtt_PackFontRangesGatherRects for a given
// pack context. The default (no oversampling) is achieved by h_oversample=1
// and v_oversample=1. The total number of pixels required is
// h_oversample*v_oversample larger than the default; for example, 2x2
// oversampling requires 4x the storage of 1x1. For best results, render
// oversampled textures with bilinear filtering. Look at the readme in
// stb/tests/oversample for information about oversampled fonts
//
// To use with PackFontRangesGather etc., you must set it before calls
// call to PackFontRangesGatherRects.
PackSetSkipMissingCodepoints :: (spc: *pack_context, skip: s32) -> void #foreign stb_truetype "stbtt_PackSetSkipMissingCodepoints";

// If skip != 0, this tells stb_truetype to skip any codepoints for which
// there is no corresponding glyph. If skip=0, which is the default, then
// codepoints without a glyph recived the font's "missing character" glyph,
// typically an empty box by convention.
GetPackedQuad :: (chardata: *packedchar, pw: s32, ph: s32, char_index: s32, xpos: *float, ypos: *float, q: *aligned_quad, align_to_integer: s32) -> void #foreign stb_truetype "stbtt_GetPackedQuad";

PackFontRangesGatherRects :: (spc: *pack_context, info: *fontinfo, ranges: *pack_range, num_ranges: s32, rects: *stbrp_rect) -> s32 #foreign stb_truetype "stbtt_PackFontRangesGatherRects";
PackFontRangesPackRects :: (spc: *pack_context, rects: *stbrp_rect, num_rects: s32) -> void #foreign stb_truetype "stbtt_PackFontRangesPackRects";
PackFontRangesRenderIntoRects :: (spc: *pack_context, info: *fontinfo, ranges: *pack_range, num_ranges: s32, rects: *stbrp_rect) -> s32 #foreign stb_truetype "stbtt_PackFontRangesRenderIntoRects";

// this is an opaque structure that you shouldn't mess with which holds
// all the context needed from PackBegin to PackEnd.
pack_context :: struct {
    user_allocator_context: *void;
    pack_info:              *void;
    width:                  s32;
    height:                 s32;
    stride_in_bytes:        s32;
    padding:                s32;
    skip_missing:           s32;
    h_oversample:           u32;
    v_oversample:           u32;
    pixels:                 *u8;
    nodes:                  *void;
}

//////////////////////////////////////////////////////////////////////////////
//
// FONT LOADING
//
//
GetNumberOfFonts :: (data: *u8) -> s32 #foreign stb_truetype "stbtt_GetNumberOfFonts";

// This function will determine the number of fonts in a font file.  TrueType
// collection (.ttc) files may contain multiple fonts, while TrueType font
// (.ttf) files only contain one font. The number of fonts can be used for
// indexing with the previous function where the index is between zero and one
// less than the total fonts. If an error occurs, -1 is returned.
GetFontOffsetForIndex :: (data: *u8, index: s32) -> s32 #foreign stb_truetype "stbtt_GetFontOffsetForIndex";

// The following structure is defined publicly so you can declare one on
// the stack or as a global or etc, but you should treat it as opaque.
fontinfo :: struct {
    userdata:         *void;
    data:             *u8; // pointer to .ttf file
    fontstart:        s32; // offset of start of font

    numGlyphs:        s32; // number of glyphs, needed for range checking

    loca:             s32; // table locations as offset from start of .ttf
    head:             s32; // table locations as offset from start of .ttf
    glyf:             s32; // table locations as offset from start of .ttf
    hhea:             s32; // table locations as offset from start of .ttf
    hmtx:             s32; // table locations as offset from start of .ttf
    kern:             s32; // table locations as offset from start of .ttf
    gpos:             s32; // table locations as offset from start of .ttf
    svg:              s32; // table locations as offset from start of .ttf
    index_map:        s32; // a cmap mapping for our chosen character encoding
    indexToLocFormat: s32; // format needed to map from glyph index to glyph

    cff:              buf; // cff font data
    charstrings:      buf; // the charstring index
    gsubrs:           buf; // global charstring subroutines index
    subrs:            buf; // private charstring subroutines index
    fontdicts:        buf; // array of font dicts
    fdselect:         buf; // map from glyph to fontdict
}

InitFont :: (info: *fontinfo, data: *u8, offset: s32) -> s32 #foreign stb_truetype "stbtt_InitFont";

//////////////////////////////////////////////////////////////////////////////
//
// CHARACTER TO GLYPH-INDEX CONVERSIOn
FindGlyphIndex :: (info: *fontinfo, unicode_codepoint: s32) -> s32 #foreign stb_truetype "stbtt_FindGlyphIndex";

//////////////////////////////////////////////////////////////////////////////
//
// CHARACTER PROPERTIES
//
ScaleForPixelHeight :: (info: *fontinfo, pixels: float) -> float #foreign stb_truetype "stbtt_ScaleForPixelHeight";

// computes a scale factor to produce a font whose "height" is 'pixels' tall.
// Height is measured as the distance from the highest ascender to the lowest
// descender; in other words, it's equivalent to calling stbtt_GetFontVMetrics
// and computing:
//       scale = pixels / (ascent - descent)
// so if you prefer to measure height by the ascent only, use a similar calculation.
ScaleForMappingEmToPixels :: (info: *fontinfo, pixels: float) -> float #foreign stb_truetype "stbtt_ScaleForMappingEmToPixels";

// computes a scale factor to produce a font whose EM size is mapped to
// 'pixels' tall. This is probably what traditional APIs compute, but
// I'm not positive.
GetFontVMetrics :: (info: *fontinfo, ascent: *s32, descent: *s32, lineGap: *s32) -> void #foreign stb_truetype "stbtt_GetFontVMetrics";

// ascent is the coordinate above the baseline the font extends; descent
// is the coordinate below the baseline the font extends (i.e. it is typically negative)
// lineGap is the spacing between one row's descent and the next row's ascent...
// so you should advance the vertical position by "*ascent - *descent + *lineGap"
//   these are expressed in unscaled coordinates, so you must multiply by
//   the scale factor for a given size
GetFontVMetricsOS2 :: (info: *fontinfo, typoAscent: *s32, typoDescent: *s32, typoLineGap: *s32) -> s32 #foreign stb_truetype "stbtt_GetFontVMetricsOS2";

// analogous to GetFontVMetrics, but returns the "typographic" values from the OS/2
// table (specific to MS/Windows TTF files).
//
// Returns 1 on success (table present), 0 on failure.
GetFontBoundingBox :: (info: *fontinfo, x0: *s32, y0: *s32, x1: *s32, y1: *s32) -> void #foreign stb_truetype "stbtt_GetFontBoundingBox";

// the bounding box around all possible characters
GetCodepointHMetrics :: (info: *fontinfo, codepoint: s32, advanceWidth: *s32, leftSideBearing: *s32) -> void #foreign stb_truetype "stbtt_GetCodepointHMetrics";

// leftSideBearing is the offset from the current horizontal position to the left edge of the character
// advanceWidth is the offset from the current horizontal position to the next horizontal position
//   these are expressed in unscaled coordinates
GetCodepointKernAdvance :: (info: *fontinfo, ch1: s32, ch2: s32) -> s32 #foreign stb_truetype "stbtt_GetCodepointKernAdvance";

// an additional amount to add to the 'advance' value between ch1 and ch2
GetCodepointBox :: (info: *fontinfo, codepoint: s32, x0: *s32, y0: *s32, x1: *s32, y1: *s32) -> s32 #foreign stb_truetype "stbtt_GetCodepointBox";

// Gets the bounding box of the visible part of the glyph, in unscaled coordinates
GetGlyphHMetrics :: (info: *fontinfo, glyph_index: s32, advanceWidth: *s32, leftSideBearing: *s32) -> void #foreign stb_truetype "stbtt_GetGlyphHMetrics";
GetGlyphKernAdvance :: (info: *fontinfo, glyph1: s32, glyph2: s32) -> s32 #foreign stb_truetype "stbtt_GetGlyphKernAdvance";
GetGlyphBox :: (info: *fontinfo, glyph_index: s32, x0: *s32, y0: *s32, x1: *s32, y1: *s32) -> s32 #foreign stb_truetype "stbtt_GetGlyphBox";

// as above, but takes one or more glyph indices for greater efficiency
kerningentry :: struct {
    glyph1:  s32; // use stbtt_FindGlyphIndex
    glyph2:  s32;
    advance: s32;
}

GetKerningTableLength :: (info: *fontinfo) -> s32 #foreign stb_truetype "stbtt_GetKerningTableLength";
GetKerningTable :: (info: *fontinfo, table: *kerningentry, table_length: s32) -> s32 #foreign stb_truetype "stbtt_GetKerningTable";

v :: enum u32 {
    move  :: 1;
    line  :: 2;
    curve :: 3;
    cubic :: 4;

    STBTT_vmove  :: move;
    STBTT_vline  :: line;
    STBTT_vcurve :: curve;
    STBTT_vcubic :: cubic;
}

vertex :: struct {
    x:       s16;
    y:       s16;
    cx:      s16;
    cy:      s16;
    cx1:     s16;
    cy1:     s16;
    type:    u8;
    padding: u8;
}

IsGlyphEmpty :: (info: *fontinfo, glyph_index: s32) -> s32 #foreign stb_truetype "stbtt_IsGlyphEmpty";

// returns non-zero if nothing is drawn for this glyph
GetCodepointShape :: (info: *fontinfo, unicode_codepoint: s32, vertices: **vertex) -> s32 #foreign stb_truetype "stbtt_GetCodepointShape";
GetGlyphShape :: (info: *fontinfo, glyph_index: s32, vertices: **vertex) -> s32 #foreign stb_truetype "stbtt_GetGlyphShape";

// returns # of vertices and fills *vertices with the pointer to them
//   these are expressed in "unscaled" coordinates
//
// The shape is a series of contours. Each one starts with
// a STBTT_moveto, then consists of a series of mixed
// STBTT_lineto and STBTT_curveto segments. A lineto
// draws a line from previous endpoint to its x,y; a curveto
// draws a quadratic bezier from previous endpoint to
// its x,y, using cx,cy as the bezier control point.
FreeShape :: (info: *fontinfo, vertices: *vertex) -> void #foreign stb_truetype "stbtt_FreeShape";

// frees the data allocated above
FindSVGDoc :: (info: *fontinfo, gl: s32) -> *u8 #foreign stb_truetype "stbtt_FindSVGDoc";
GetCodepointSVG :: (info: *fontinfo, unicode_codepoint: s32, svg: **u8) -> s32 #foreign stb_truetype "stbtt_GetCodepointSVG";
GetGlyphSVG :: (info: *fontinfo, gl: s32, svg: **u8) -> s32 #foreign stb_truetype "stbtt_GetGlyphSVG";

//////////////////////////////////////////////////////////////////////////////
//
// BITMAP RENDERING
//
FreeBitmap :: (bitmap: *u8, userdata: *void) -> void #foreign stb_truetype "stbtt_FreeBitmap";

// frees the bitmap allocated below
GetCodepointBitmap :: (info: *fontinfo, scale_x: float, scale_y: float, codepoint: s32, width: *s32, height: *s32, xoff: *s32, yoff: *s32) -> *u8 #foreign stb_truetype "stbtt_GetCodepointBitmap";

// allocates a large-enough single-channel 8bpp bitmap and renders the
// specified character/glyph at the specified scale into it, with
// antialiasing. 0 is no coverage (transparent), 255 is fully covered (opaque).
// *width & *height are filled out with the width & height of the bitmap,
// which is stored left-to-right, top-to-bottom.
//
// xoff/yoff are the offset it pixel space from the glyph origin to the top-left of the bitmap
GetCodepointBitmapSubpixel :: (info: *fontinfo, scale_x: float, scale_y: float, shift_x: float, shift_y: float, codepoint: s32, width: *s32, height: *s32, xoff: *s32, yoff: *s32) -> *u8 #foreign stb_truetype "stbtt_GetCodepointBitmapSubpixel";

// the same as stbtt_GetCodepoitnBitmap, but you can specify a subpixel
// shift for the character
MakeCodepointBitmap :: (info: *fontinfo, output: *u8, out_w: s32, out_h: s32, out_stride: s32, scale_x: float, scale_y: float, codepoint: s32) -> void #foreign stb_truetype "stbtt_MakeCodepointBitmap";

// the same as stbtt_GetCodepointBitmap, but you pass in storage for the bitmap
// in the form of 'output', with row spacing of 'out_stride' bytes. the bitmap
// is clipped to out_w/out_h bytes. Call stbtt_GetCodepointBitmapBox to get the
// width and height and positioning info for it first.
MakeCodepointBitmapSubpixel :: (info: *fontinfo, output: *u8, out_w: s32, out_h: s32, out_stride: s32, scale_x: float, scale_y: float, shift_x: float, shift_y: float, codepoint: s32) -> void #foreign stb_truetype "stbtt_MakeCodepointBitmapSubpixel";

// same as stbtt_MakeCodepointBitmap, but you can specify a subpixel
// shift for the character
MakeCodepointBitmapSubpixelPrefilter :: (info: *fontinfo, output: *u8, out_w: s32, out_h: s32, out_stride: s32, scale_x: float, scale_y: float, shift_x: float, shift_y: float, oversample_x: s32, oversample_y: s32, sub_x: *float, sub_y: *float, codepoint: s32) -> void #foreign stb_truetype "stbtt_MakeCodepointBitmapSubpixelPrefilter";

// same as stbtt_MakeCodepointBitmapSubpixel, but prefiltering
// is performed (see stbtt_PackSetOversampling)
GetCodepointBitmapBox :: (font: *fontinfo, codepoint: s32, scale_x: float, scale_y: float, ix0: *s32, iy0: *s32, ix1: *s32, iy1: *s32) -> void #foreign stb_truetype "stbtt_GetCodepointBitmapBox";

// get the bbox of the bitmap centered around the glyph origin; so the
// bitmap width is ix1-ix0, height is iy1-iy0, and location to place
// the bitmap top left is (leftSideBearing*scale,iy0).
// (Note that the bitmap uses y-increases-down, but the shape uses
// y-increases-up, so CodepointBitmapBox and CodepointBox are inverted.)
GetCodepointBitmapBoxSubpixel :: (font: *fontinfo, codepoint: s32, scale_x: float, scale_y: float, shift_x: float, shift_y: float, ix0: *s32, iy0: *s32, ix1: *s32, iy1: *s32) -> void #foreign stb_truetype "stbtt_GetCodepointBitmapBoxSubpixel";

// the following functions are equivalent to the above functions, but operate
// on glyph indices instead of Unicode codepoints (for efficiency)
GetGlyphBitmap :: (info: *fontinfo, scale_x: float, scale_y: float, glyph: s32, width: *s32, height: *s32, xoff: *s32, yoff: *s32) -> *u8 #foreign stb_truetype "stbtt_GetGlyphBitmap";
GetGlyphBitmapSubpixel :: (info: *fontinfo, scale_x: float, scale_y: float, shift_x: float, shift_y: float, glyph: s32, width: *s32, height: *s32, xoff: *s32, yoff: *s32) -> *u8 #foreign stb_truetype "stbtt_GetGlyphBitmapSubpixel";
MakeGlyphBitmap :: (info: *fontinfo, output: *u8, out_w: s32, out_h: s32, out_stride: s32, scale_x: float, scale_y: float, glyph: s32) -> void #foreign stb_truetype "stbtt_MakeGlyphBitmap";
MakeGlyphBitmapSubpixel :: (info: *fontinfo, output: *u8, out_w: s32, out_h: s32, out_stride: s32, scale_x: float, scale_y: float, shift_x: float, shift_y: float, glyph: s32) -> void #foreign stb_truetype "stbtt_MakeGlyphBitmapSubpixel";
MakeGlyphBitmapSubpixelPrefilter :: (info: *fontinfo, output: *u8, out_w: s32, out_h: s32, out_stride: s32, scale_x: float, scale_y: float, shift_x: float, shift_y: float, oversample_x: s32, oversample_y: s32, sub_x: *float, sub_y: *float, glyph: s32) -> void #foreign stb_truetype "stbtt_MakeGlyphBitmapSubpixelPrefilter";
GetGlyphBitmapBox :: (font: *fontinfo, glyph: s32, scale_x: float, scale_y: float, ix0: *s32, iy0: *s32, ix1: *s32, iy1: *s32) -> void #foreign stb_truetype "stbtt_GetGlyphBitmapBox";
GetGlyphBitmapBoxSubpixel :: (font: *fontinfo, glyph: s32, scale_x: float, scale_y: float, shift_x: float, shift_y: float, ix0: *s32, iy0: *s32, ix1: *s32, iy1: *s32) -> void #foreign stb_truetype "stbtt_GetGlyphBitmapBoxSubpixel";

// @TODO: don't expose this structure
bitmap :: struct {
    w:      s32;
    h:      s32;
    stride: s32;
    pixels: *u8;
}

// rasterize a shape with quadratic beziers into a bitmap
Rasterize :: (result: *bitmap, flatness_in_pixels: float, vertices: *vertex, num_verts: s32, scale_x: float, scale_y: float, shift_x: float, shift_y: float, x_off: s32, y_off: s32, invert: s32, userdata: *void) -> void #foreign stb_truetype "stbtt_Rasterize";

//////////////////////////////////////////////////////////////////////////////
//
// Signed Distance Function (or Field) rendering
FreeSDF :: (bitmap: *u8, userdata: *void) -> void #foreign stb_truetype "stbtt_FreeSDF";

// frees the SDF bitmap allocated below
GetGlyphSDF :: (info: *fontinfo, scale: float, glyph: s32, padding: s32, onedge_value: u8, pixel_dist_scale: float, width: *s32, height: *s32, xoff: *s32, yoff: *s32) -> *u8 #foreign stb_truetype "stbtt_GetGlyphSDF";
GetCodepointSDF :: (info: *fontinfo, scale: float, codepoint: s32, padding: s32, onedge_value: u8, pixel_dist_scale: float, width: *s32, height: *s32, xoff: *s32, yoff: *s32) -> *u8 #foreign stb_truetype "stbtt_GetCodepointSDF";

//////////////////////////////////////////////////////////////////////////////
//
// Finding the right font...
//
// You should really just solve this offline, keep your own tables
// of what font is what, and don't try to get it out of the .ttf file.
// That's because getting it out of the .ttf file is really hard, because
// the names in the file can appear in many possible encodings, in many
// possible languages, and e.g. if you need a case-insensitive comparison,
// the details of that depend on the encoding & language in a complex way
// (actually underspecified in truetype, but also gigantic).
//
// But you can use the provided functions in two possible ways:
//     stbtt_FindMatchingFont() will use *case-sensitive* comparisons on
//             unicode-encoded names to try to find the font you want;
//             you can run this before calling stbtt_InitFont()
//
//     stbtt_GetFontNameString() lets you get any of the various strings
//             from the file yourself and do your own comparisons on them.
//             You have to have called stbtt_InitFont() first.
FindMatchingFont :: (fontdata: *u8, name: *u8, flags: s32) -> s32 #foreign stb_truetype "stbtt_FindMatchingFont";

CompareUTF8toUTF16_bigendian :: (s1: *u8, len1: s32, s2: *u8, len2: s32) -> s32 #foreign stb_truetype "stbtt_CompareUTF8toUTF16_bigendian";

// returns 1/0 whether the first string interpreted as utf8 is identical to
// the second string interpreted as big-endian utf16... useful for strings from next func
GetFontNameString :: (font: *fontinfo, length: *s32, platformID: s32, encodingID: s32, languageID: s32, nameID: s32) -> *u8 #foreign stb_truetype "stbtt_GetFontNameString";

// returns the string (which may be big-endian double byte, e.g. for unicode)
// and puts the length in bytes in *length.
//
// some of the values for the IDs are below; for more see the truetype spec:
//     http://developer.apple.com/textfonts/TTRefMan/RM06/Chap6name.html
//     http://www.microsoft.com/typography/otspec/name.htm
PLATFORM_ID :: enum u32 {
    UNICODE   :: 0;
    MAC       :: 1;
    ISO       :: 2;
    MICROSOFT :: 3;

    STBTT_PLATFORM_ID_UNICODE   :: UNICODE;
    STBTT_PLATFORM_ID_MAC       :: MAC;
    STBTT_PLATFORM_ID_ISO       :: ISO;
    STBTT_PLATFORM_ID_MICROSOFT :: MICROSOFT;
}

UNICODE_EID :: enum u32 {
    UNICODE_1_0      :: 0;
    UNICODE_1_1      :: 1;
    ISO_10646        :: 2;
    UNICODE_2_0_BMP  :: 3;
    UNICODE_2_0_FULL :: 4;

    STBTT_UNICODE_EID_UNICODE_1_0      :: UNICODE_1_0;
    STBTT_UNICODE_EID_UNICODE_1_1      :: UNICODE_1_1;
    STBTT_UNICODE_EID_ISO_10646        :: ISO_10646;
    STBTT_UNICODE_EID_UNICODE_2_0_BMP  :: UNICODE_2_0_BMP;
    STBTT_UNICODE_EID_UNICODE_2_0_FULL :: UNICODE_2_0_FULL;
}

MS_EID :: enum u32 {
    SYMBOL       :: 0;
    UNICODE_BMP  :: 1;
    SHIFTJIS     :: 2;
    UNICODE_FULL :: 10;

    STBTT_MS_EID_SYMBOL       :: SYMBOL;
    STBTT_MS_EID_UNICODE_BMP  :: UNICODE_BMP;
    STBTT_MS_EID_SHIFTJIS     :: SHIFTJIS;
    STBTT_MS_EID_UNICODE_FULL :: UNICODE_FULL;
}

MAC_EID :: enum u32 {
    ROMAN        :: 0;
    ARABIC       :: 4;
    JAPANESE     :: 1;
    HEBREW       :: 5;
    CHINESE_TRAD :: 2;
    GREEK        :: 6;
    KOREAN       :: 3;
    RUSSIAN      :: 7;

    STBTT_MAC_EID_ROMAN        :: ROMAN;
    STBTT_MAC_EID_ARABIC       :: ARABIC;
    STBTT_MAC_EID_JAPANESE     :: JAPANESE;
    STBTT_MAC_EID_HEBREW       :: HEBREW;
    STBTT_MAC_EID_CHINESE_TRAD :: CHINESE_TRAD;
    STBTT_MAC_EID_GREEK        :: GREEK;
    STBTT_MAC_EID_KOREAN       :: KOREAN;
    STBTT_MAC_EID_RUSSIAN      :: RUSSIAN;
}

MS_LANG :: enum u32 {
    ENGLISH  :: 1033;
    ITALIAN  :: 1040;
    CHINESE  :: 2052;
    JAPANESE :: 1041;
    DUTCH    :: 1043;
    KOREAN   :: 1042;
    FRENCH   :: 1036;
    RUSSIAN  :: 1049;
    GERMAN   :: 1031;
    SPANISH  :: 1033;
    HEBREW   :: 1037;
    SWEDISH  :: 1053;

    STBTT_MS_LANG_ENGLISH  :: ENGLISH;
    STBTT_MS_LANG_ITALIAN  :: ITALIAN;
    STBTT_MS_LANG_CHINESE  :: CHINESE;
    STBTT_MS_LANG_JAPANESE :: JAPANESE;
    STBTT_MS_LANG_DUTCH    :: DUTCH;
    STBTT_MS_LANG_KOREAN   :: KOREAN;
    STBTT_MS_LANG_FRENCH   :: FRENCH;
    STBTT_MS_LANG_RUSSIAN  :: RUSSIAN;
    STBTT_MS_LANG_GERMAN   :: GERMAN;
    STBTT_MS_LANG_SPANISH  :: SPANISH;
    STBTT_MS_LANG_HEBREW   :: HEBREW;
    STBTT_MS_LANG_SWEDISH  :: SWEDISH;
}

MAC_LANG :: enum u32 {
    ENGLISH            :: 0;
    JAPANESE           :: 11;
    ARABIC             :: 12;
    KOREAN             :: 23;
    DUTCH              :: 4;
    RUSSIAN            :: 32;
    FRENCH             :: 1;
    SPANISH            :: 6;
    GERMAN             :: 2;
    SWEDISH            :: 5;
    HEBREW             :: 10;
    CHINESE_SIMPLIFIED :: 33;
    ITALIAN            :: 3;
    CHINESE_TRAD       :: 19;

    STBTT_MAC_LANG_ENGLISH            :: ENGLISH;
    STBTT_MAC_LANG_JAPANESE           :: JAPANESE;
    STBTT_MAC_LANG_ARABIC             :: ARABIC;
    STBTT_MAC_LANG_KOREAN             :: KOREAN;
    STBTT_MAC_LANG_DUTCH              :: DUTCH;
    STBTT_MAC_LANG_RUSSIAN            :: RUSSIAN;
    STBTT_MAC_LANG_FRENCH             :: FRENCH;
    STBTT_MAC_LANG_SPANISH            :: SPANISH;
    STBTT_MAC_LANG_GERMAN             :: GERMAN;
    STBTT_MAC_LANG_SWEDISH            :: SWEDISH;
    STBTT_MAC_LANG_HEBREW             :: HEBREW;
    STBTT_MAC_LANG_CHINESE_SIMPLIFIED :: CHINESE_SIMPLIFIED;
    STBTT_MAC_LANG_ITALIAN            :: ITALIAN;
    STBTT_MAC_LANG_CHINESE_TRAD       :: CHINESE_TRAD;
}

#scope_file


#if OS == .WINDOWS {
    stb_truetype :: #library "windows/stb_truetype";
} else #if OS == .LINUX {
    stb_truetype :: #library "linux/stb_truetype";
} else #if OS == .MACOS {
    stb_truetype :: #library "macos/stb_truetype";
} else #if OS == .ANDROID {
    #if CPU == .X64 {
        stb_truetype :: #library "android/x64/stb_truetype";
    } else #if CPU == .ARM64 {
        stb_truetype :: #library "android/arm64/stb_truetype";
    }
} else #if OS == .PS5 {
    stb_truetype :: #library "ps5/stb_truetype";
} else {
    #assert false;
}

