## Load

using JuMP, Gurobi, MosekTools, Mosek, LinearAlgebra, DiffOpt

## Direct model

nonlinear_model = Model(Gurobi.Optimizer)

set_optimizer_attribute(nonlinear_model, "NonConvex", 2)

@variable(nonlinear_model, x)

@variable(nonlinear_model, y)

@constraint(nonlinear_model, con1, x^2 + y^2 - 4 == 0)

@constraint(nonlinear_model, con2, (x-1)^2 + y^2 - 4 == 0)

@objective(nonlinear_model, Min, x)

optimize!(nonlinear_model)

p_star = objective_value(nonlinear_model)

x_star = value.(x)

@show p_star

@show x_star
## Finding the coefficient matrices one by one

object_1 = JuMP.constraint_object(con1)
quad_func_1 = JuMP.moi_function(object_1)
matrix_1 = DiffOpt.sparse_array_representation(quad_func_1)

object_2 = JuMP.constraint_object(con2)

## SDP relaxation model

sdp_model = Model(Mosek.Optimizer)

@variable(sdp_model, x[1:2])

@variable(sdp_model, X[1:2, 1:2], Symmetric)

@constraint(sdp_model, tr(X) == 4)

@constraint(sdp_model, tr(X) - 2*[1;0]'*x - 3 == 0)

@constraint(sdp_model, [X x;
                        x' 1] in PSDCone())

@objective(sdp_model, Min, x[1])

optimize!(sdp_model)

p_star_SDP = objective_value(sdp_model)

@show p_star_SDP

x_star_SDP = value.(x)

@show x_star_SDP
