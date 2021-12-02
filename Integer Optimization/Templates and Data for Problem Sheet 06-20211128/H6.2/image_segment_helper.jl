using LinearAlgebra, Plots

# compute the weight of the pixel pair (i,j), (ii,jj)
function get_weight(image, i,j, ii,jj)
    # ignore alpha; result is a vector in [0,1]^3
    rgb(i,j) = float.([
        red(image[i,j]),
        green(image[i,j]),
        blue(image[i,j])
    ])
    
    pnorm(x, p) = norm(x, p) / length(x)^(1/p)
    
    y = pnorm(rgb(i,j) - rgb(ii,jj), 2)
    0 <= y <= 1 ? nothing : throw(DomainError(y, "must be in [0,1]"))
    return (y - 0.35)^3
end


# object: list of tuples (i,j) that represent all pixels inside the object(s) found
function show_image(image, object)
    # colour object pixels in copy of input image
    colour = RGBA(1,165/255,0,1)  # :orange
    
    if length(object) > 0
        img_copy = RGBA.(image)  
        for (i,j) in object
            img_copy[i,j] = colour
        end
        plot(mosaicview(image, img_copy; fillvalue=RGBA(0,0,0,0), npad=4, nrow=1), axis=nothing)
    else
        plot(mosaicview(image), axis=nothing)
    end
end