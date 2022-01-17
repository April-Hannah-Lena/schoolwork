using Plots, PlotThemes, QuadGK, Roots
theme(:dark)

function lambda(A, sgn)
    λ = 0.0
    if length(A) == 0 && sgn[1] == true
        λ = 1e5
        return λ
    elseif length(A) == 0 && sgn[1] == false
        λ = 1e5
        return λ
    elseif x < A[1] && sgn[1] == true
        λ = 1e5
        return λ
    elseif x >= A[end] && sgn[end] == true
        λ = 1e5
        return λ
    end

    if length(A) > 1
        while k in l:length(A)-1
            if A[i] <= x < A[i+1] && sgn[i+1] == true
                λ = A[i+1] - A[i]
                k += 1
            end
        end
    end

    return λ
end

function greaterRange(f, t)
    f_0 = collect(fzeros(x -> f(x) - t, -1e5, 1e5))
    sgn = trues(length(f_0) + 1)
    for z in f_0
        sgn[i] = f(z - 1e-2) > 0 ? true : false
    end
    sgn[end] = f(f_0[end] + 1e-2) > 0 ? true : false
    
    return f_0, sgn
end

function star(f, x)
    function ind(x, t)
        f_0, sgn = greaterRange(f, t)
        greaterRangeStar = [- lambda(f_0, sgn), lambda(f_0, sgn)]
        if greaterRangeStar[1] < x < greaterRangeStar[2]
            return 1.0
        else
            return 0.0
        end
    end

    return quadgk(t -> ind(x, t), -1e5, 1e5, rtol=1e-5)
end

f(x) = -π/2 <= x <= 3π/2 ? sin(x) : -1.0
h = 0.5
p1 = plot(x -> f(x), xlims=(-3, 5), leg=false)
p1 = plot!(x -> h, leg=false)
p2 = p1
p2 = plot!(sin, x -> cos(x),0, 2π, leg=false, fill=(0, :orange))
p3 = plot(x -> star(f, x), lims=(-3, 5), leg=false)
p3 = plot!(x -> h, leg=false)


#ind(t) = quadgk(a -> begin
#f(a) > t ? 1.0 : 0.0
#end, 
#-1e5, 1e5, rtol=1e-5)

#function λ(D)
#    dim = length(D)
#    lambda = 0.0
#    for i in 1:dim
#        lambda = lambda * (A[i[end]] - A[i[1]])
#    end
#    return lambda
#end
#function ω(D)
#    π^(D/2) / factorial((D/2)+1)
#end
#function τ(D)
#    dim = length(D)
#    return (λ(D) / ω(dim)) ^ (1/dim)
#end

#while k in l:length(f_0)-1
#    if f_0[i] <= x < f_0[i+1] && sgn[i+1] == true
#        return 1.0
#    else
#        k += 1
#    end
#end
#if x < f_0[1] && sgn[1] == true
#    return 1.0
#end
#if x >= f_0[end] && sgn[end] == true
#    return 1.0
#end