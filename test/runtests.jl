using EvalDataFrames
using Test
using DataFrames, Unitful

@testset "EvalDataFrames.eval!" begin
    df = DataFrame(A = ["1","2","3"]) |> eval!
    @test df.A == [1,2,3]

    df = DataFrame(A = ["[1,2,3]","[2,4]"]) |> eval!
    @test df.A == [[1,2,3],[2,4]]

    df = DataFrame(A = ["1+2","sqrt(2)"]) |> eval!
    @test df.A == [3,sqrt(2)]
end

@testset "EvalDataFrames.eval! + Unitful" begin
    @test eval("1u\"mm\"" |> Meta.parse) == 1u"mm" 

    df = DataFrame(A = ["1u\"m\""]) |> eval!
    @test df.A == [1u"m"]

    df = DataFrame(
        A = ["1u\"m\"","2"],
        B = ["[1u\"m\",2u\"m\",3u\"m\"]","[2u\"m\",4u\"m\"]"],
        C = [1,2],
        D = [:(1+2), :(sin(0))],
    ) |> eval!
    @test df == DataFrame(
        A = [1u"m",2],
        B = [[1u"m",2u"m",3u"m"],[2u"m",4u"m"]],
        C = [1,2],
        D = [3, sin(0)],
    )
end

@testset "EvalDataFrames.eval! multi colmun" begin
    df = DataFrame(
        A = ["1","2"],
        B = ["[1,2,3]","[2,4]"],
        C = [1,2],
        D = [:(1+2), :(sin(0))],
    ) 

    #* パイプラインの確認
    df_ = deepcopy(df)
    df_ |> eval!
    @test df_ == DataFrame(
        A = [1,2],
        B = [[1,2,3],[2,4]],
        C = [1,2],
        D = [3, sin(0)],
    )
  
    #* カラムの指定
    df_ = deepcopy(df)
    eval!(df_, :B)
    @test df_ == DataFrame(
        A = ["1","2"],
        B = [[1,2,3],[2,4]],
        C = [1,2],
        D = [:(1+2), :(sin(0))],
    )
    

    #* 複数カラムの指定
    df_ = deepcopy(df)
    eval!(df_, [:A, :D])
    @test df_ == DataFrame(
        A = [1,2],
        B = ["[1,2,3]","[2,4]"],
        C = [1,2],
        D = [3, sin(0)],
    )
        
    #* カラムの除外
    df_ = deepcopy(df)
    eval!(df_, Not(:A))
    @test df_ == DataFrame(
        A = ["1","2"],
        B = [[1,2,3],[2,4]],
        C = [1,2],
        D = [3, sin(0)],
    )
    
    #* 複数カラムの除外
    df_ = deepcopy(df)
    eval!(df_, Not([:A, :C]))
    @test df_ == DataFrame(
        A = ["1","2"],
        B = [[1,2,3],[2,4]],
        C = [1,2],
        D = [3, sin(0)],
    )
    
    #* 全カラムの除外
    df_ = deepcopy(df)
    eval!(df_, Not(df_|>propertynames))
    @test df_ == DataFrame(
        A = ["1","2"],
        B = ["[1,2,3]","[2,4]"],
        C = [1,2],
        D = [:(1+2), :(sin(0))],
    )
end