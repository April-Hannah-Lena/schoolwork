using ProgressMeter, Serialization, SMTPClient, Dates
exit_code = false

try

    types  = ["nothing", "cpu", "gpu"]
    steps  = ceil.(Int, 10 .^ (1.0:3.0))#ceil.(Int, 10 .^ (1.0:2.0))
    points = 4 .* ceil.(Int, 10 .^ (1.0:0.2:3.0))#4 .* ceil.(Int, 10 .^ (1.0:2.0))


    times = Array{Float64,3}(undef, length(types), length(steps), length(points))
    prog = Progress(length(times), 10)
    for k in eachindex(points), j in eachindex(steps), i in eachindex(types)
        t, s, p = types[i], steps[j], points[k]
        times[i, j, k] = Meta.parse(readchomp(`julia --threads=auto boxmap_benchmark.jl $t $s $p`))
        ProgressMeter.next!(prog; showvalues=[(:t, t), (:s, s), (:p, p)])
    end

    serialize("times_points.jls", times)


    steps = ceil.(Int, 10 .^ (0.6:0.1:5.0))#ceil.(Int, 10 .^ (0.6:0.4:1.0))


    times = Array{Float64,2}(undef, length(types), length(steps))
    prog = Progress(length(times), 10)
    for j in eachindex(steps), i in eachindex(types)
        t, s = types[i], steps[j]
        times[i, j] = Meta.parse(readchomp(`julia --threads=auto boxmap_benchmark.jl $t $s 400`))
        ProgressMeter.next!(prog; showvalues=[(:t, t), (:s, s)])
    end

    serialize("times_complexity.jls", times)

catch err

    global exit_code = true

finally

    include("uname+passwd.jl")

    opt = SendOptions(
        isSSL = true,
        username = username,
        passwd = passwd
    )

    body = IOBuffer(
        "Date: $(Dates.format(Dates.now(), "e, dd u yyyy HH:MM:SS")) +0100\r\n" *
        "From: Me <$(username)>\r\n" *
        "To: $(rcpt)\r\n" *
        "Subject: Benchmark $(exit_code ? "un" : "")successfully finished\r\n" *
        "\r\n" *
        "Go turn off the computer.\r\n"
    )

    url = "smtps://smtp.gmail.com:465"
    resp = send(url, ["<$(rcpt)>"], "<$(username)>", body, opt)

end
