--[[ removeImages.lua - remove images

When rendering in PDF output, GitHub badges generate
a "Cannot determine size of graphic" LaTeX error.

This is probably because it's downloaded from 
https://img.shields.io as `ci.yaml?branch=main`
without `.svg` extension.

]]--

function Image(img)
    return {}
end

