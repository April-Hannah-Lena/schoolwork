using ProgressMeter, Serialization, SMTPClient, Dates
exit_code = false

try

types  = ["nothing", "cpu", "gpu"]
steps  = ceil.(Int, 10 .^ (1.0:3.0))
points = 4 .* ceil.(Int, 10 .^ (1.0:0.2:3.0))

times = @showprogress([
    Meta.parse(readchomp(`julia --threads=auto boxmap_benchmark.jl $t $s $p`)) 
    for t in types, s in steps, p in points
])

serialize("times_points.jls", times)


steps = ceil.(Int, 10 .^ (0.6:0.1:5.0))

times = @showprogress([
    Meta.parse(readchomp(`julia --threads=auto boxmap_benchmark.jl $t $s 400`))
    for t in types, s in steps
])

serialize("times_complexity.jls", times)

catch err

exit_code = true

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
