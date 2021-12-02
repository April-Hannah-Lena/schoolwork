using JuMP, Gurobi
using Images
include("./image_segment_helper.jl")

function segment(image)

    h, w = size(image)

    neighbors(i, j) = filter(
        ind -> (1 ≤ ind[2] ≤ h) && (1 ≤ ind[3] ≤ w),
        [
            (2, i-1, j-1), (3, i-1, j), (4, i-1, j+1), (5, i, j-1), 
            (6, i, j+1), (7, i+1, j-1), (8, i+1, j), (9, i+1, j+1)
        ]
    )

    weight_tensor = zeros(h, w, 8)

    model = Model(Gurobi.Optimizer)
    @variable(model, x[1:h, 1:w, 1:17], Bin)

    for i in 1:h, j in 1:w
        for (k, l, m) in neighbors(i, j)
            @constraint(model, x[i, j, 1] - x[l, m, 1] ≤ x[i, j, k])
            @constraint(model, x[i, j, k] ≤ x[i, j, 1])
            @constraint(model, x[l, m, 1] + x[i, j, k] ≤ 1)
            @constraint(model, x[l, m, 1] - x[i, j, 1] ≤ x[i, j, k+8])
            @constraint(model, x[i, j, k+8] ≤ x[l, m, 1])
            @constraint(model, x[i, j, 1] + x[i, j, k+8] ≤ 1)

            weight_tensor[i, j, k-1] = get_weight(image, i, j, l, m)
        end
    end
    
    @objective(model, Max, sum(weight_tensor .* (x[:, :, 2:9] .+ x[:, :, 10:17])))
    optimize!(model)
    object = value.(x[:, :, 1])

    return Tuple.(findall(isone, object))
end


# load image
img = load("img1.jpg")   # change file path here to load a different image file
# detect object(s)
object_pixels = segment(img)
# display result
show_image(img, object_pixels)

