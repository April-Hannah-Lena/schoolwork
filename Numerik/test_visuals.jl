using GPUArrays, oneAPI, Colors

struct CV_GPUPortraitPainter{trafoT, CS} <: CV_2DCanvasPainter
    trafo       :: trafoT
    colorscheme :: CS
    domain      :: oneArray{ComplexF32, 2}
end

function CV_GPUPortraitPainter(trafo::trafoT=identity,
        colorscheme::CS=ComplexPortraits.cs_j(),
        domain::CV_Math2DCanvas) where {trafoT, CS}

    return CV_GPUPortraitPainter{trafoT, CS}(
        trafo, colorscheme,
        oneArray{ComplexF32, 2}(
            [x + y*1im for y in LinRange{Float32}(imag(domain.corner_lr), imag(domain.corner_ul), domain.pixel_height),
                           x in LinRange{Float32}(real(domain.corner_ul), real(domain.corner_lr), domain.pixel_width)]
        )
    )
end

import ComplexVisual: cv_paint
function cv_paint(cc::CV_2DCanvasContext{canvasT},
                  portrait_painter::CV_GPUPortraitPainter{CS}
                 )  where {canvasT <: CV_Math2DCanvas, CS}

    point_color = portrait_painter.colorscheme
    color_matrix = map(portrait_painter.domain) do z
        convert( Colors.ARGB32, point_color(z, f(z)) ).color
    end :: oneArray{UInt32, 2}
    oneAPI.synchronize(color_matrix)
    color_matrix = Array(color_matrix)'

    #color_argb32 = map(Array(color_matrix)) do co
    #    convert(Colors.ARGB32, co).color
    #end
    surface = cc.canvas.surface
    Cairo.flush(surface)
    surface.data .= color_matrix
    #surface.data .= color_argb32'
    Cairo.mark_dirty(surface)
    return nothing
end
