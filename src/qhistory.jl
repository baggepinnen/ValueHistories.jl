mutable struct QHistory{I,V} <: UnivalueHistory{I}
    lastiter::I
    storage::Deque{Tuple{I,V}}

    function QHistory(::Type{V}, ::Type{I} = Int) where {I,V}
        new{I,V}(typemin(I), Deque{Tuple{I,V}}())
    end
end

# ====================================================================

Base.length(history::QHistory) = length(history.storage)
Base.enumerate(history::QHistory) = history.storage
Base.first(history::QHistory) = front(history.storage)
Base.last(history::QHistory) = back(history.storage)

function Base.push!(
        history::QHistory{I,V},
        iteration::I,
        value::V) where {I,V}
    lastiter = history.lastiter
    iteration > lastiter || throw(ArgumentError("Iterations must increase over time"))
    history.lastiter = iteration
    push!(history.storage, (iteration, value))
    value
end

function Base.push!(
        history::QHistory{I,V},
        value::V) where {I,V}
    lastiter = history.lastiter == typemin(I) ? zero(I) : history.lastiter
    iteration = lastiter + one(history.lastiter)
    history.lastiter = iteration
    push!(history.storage, (iteration, value))
    value
end

function Base.get(history::QHistory{I,V}) where {I,V}
    l = length(history)
    k, v = front(history.storage)
    karray = zeros(I, l)
    varray = Array{V}(l)
    i = 1
    for (k, v) in enumerate(history)
        karray[i] = k
        varray[i] = v
        i += 1
    end
    karray, varray
end

Base.print(io::IO, history::QHistory{I,V}) where {I,V} = print(io, "$(length(history)) elements {$I,$V}")

function Base.show(io::IO, history::QHistory{I,V}) where {I,V}
    println(io, "QHistory")
    println(io, "    types: $I, $V")
    print(io,   "    length: $(length(history))")
end
