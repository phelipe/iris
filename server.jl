using Merly
using MLJ
using DataFrames
using DecisionTree
using HTTP
using JSON

#server = App("0.0.0.0", parse(Int,ARGS[1])) 
server = App("127.0.0.1", 8086) 

useCORS(true)
webserverpath(server, "public")
webserverfiles(server, "*")

RandomForestClassifier()
const _jlsopath = String(joinpath(@__DIR__,"modelo2.jlso"))
mach_load = machine(_jlsopath)

# function returnhtmlfile(s::String)
#     f = open(s)
#     read(f, String)    
# end

function predict_iris(in1::T, in2::T, in3::T) where {T<:Float64}
    predict_mode( mach_load, DataFrame([[in1],[in2],[in3]], [:sepallength,:sepalwidth,:petallength]))[1]
end

#@page "/" File("/public/index.html")
Get("/", (req,res)->(begin
    res.headers["Content-Type"]= "text/html"
    File(server, "index.html")
end))

Post("/dados", (req,res)->(begin
        res.headers["Content-Type"]="application/json"
        dados = JSON.parse(req.body)

        try
            in1 = typeof(dados["entrada1"]) == Float64 ? dados["entrada1"] : parse(Float64, dados["entrada1"])
            in2 = typeof(dados["entrada2"]) == Float64 ? dados["entrada2"] : parse(Float64, dados["entrada2"])
            in3 = typeof(dados["entrada3"]) == Float64 ? dados["entrada3"] : parse(Float64, dados["entrada3"])

            res.body = JSON.json(predict_iris(in1, in2, in3))
        catch erro
            @show erro
            res.status = 200
            JSON.json("tipo errado informado")
        end
end))

start(server, verbose = false)


