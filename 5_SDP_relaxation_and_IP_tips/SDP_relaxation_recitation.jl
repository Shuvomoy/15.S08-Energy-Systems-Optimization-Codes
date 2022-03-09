## Load

using JuMP, Gurobi, MosekTools, Mosek, LinearAlgebra

## Direct model

nonlinear_model = Model(Gurobi.Optimizer)

set_optimizer_attribute(nonlinear_model, "NonConvex", 2)

@variable(nonlinear_model, x[1:2])

@constraint(nonlinear_model, x[1]^2 + x[2]^2 == 4)

@constraint(nonlinear_model, (x[1]-1)^2 + x[2]^2 == 4)

@objective(nonlinear_model, Min, x[1])

optimize!(nonlinear_model)

p_star = objective_value(nonlinear_model)

x_star = value.(x)

@show p_star

@show x_star
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
