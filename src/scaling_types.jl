abstract type AbstractScaling{F1 <: Number} end

"""
	$(SIGNATURES)

No scaling. `f(d) = d`.
Deviation = sum of abs(f(d) - f(m)) ^ p
"""
struct ScalingNone{F1} <: AbstractScaling{F1}
    p :: F1
end

"""
	$(SIGNATURES)

Linear scaling with fixed parameters. 
`f(d) = (f0 + f1 * (m - d)) ^ p - f0`.
For percentiles, this could be `f0 = f1 = 1`.
"""
struct ScalingLinear{F1} <: AbstractScaling{F1}
    f0 :: F1
    slope :: F1
    p :: F1
end

"""
	$(SIGNATURES)

Relative scaling.
`f(d) = abs((m - d) / scale) ^ p`
"""
struct ScalingRelative{F1} <: AbstractScaling{F1}
    scale :: F1
    p :: F1
end


# ---------------------