module IntegLACore

LIBNAME = "IntegLA"

TYPE_NAMES = Dict{String,String}(
    "double" => "f64Vec",
    "float" => "f32Vec",
    "int64_t" => "f64Vec",
    "int32_t" => "i32Vec",
)

CONVERT_LIST = Dict{String,String}(
    "{Vec0}" => "x",
    "{Vec1}" => "y",
    "{Vec2}" => "z",
    "{Val0}" => "alpha",
    "{Val1}" => "beta",
    "{Val2}" => "gamma",
    "{INT}" => "size_t",
)

struct ArgType
    target::String
    type::String
    name::String
    puretype::String
end

function ArgType(target::String, type_name::Tuple{String,String})
    type = replace(
        type_name[begin],
        "{target}" => target,
        "{Vec}" => TYPE_NAMES[target],
        CONVERT_LIST...,
    )
    name = replace(
        type_name[end],
        "{target}" => target,
        "{Vec}" => TYPE_NAMES[target],
        CONVERT_LIST...,
    )
    puretype = replace(type, "const " => "")
    ArgType(target, type, name, puretype)
end

struct FunctionDef
    argtypes::Vector{ArgType} # TemplateString
    purename::String
    name::String
    ret::String
    declare::String
    prototype::String
end

struct Code
    operation::String
    code::String
    op::String
end

function Code(; declare, operation, target)
    code = declare * "{\n"
    op = replace(
        operation,
        "{target}" => target,
        "{Vec}" => TYPE_NAMES[target],
        CONVERT_LIST...,
    )
    code *= op * "}\n"
    Code(operation, code, op)
end

function FunctionDef(;
    purename::String,
    group::String,
    ret::String,
    target::String,
    args::Vector{Tuple{String,String}}
)
    argtypes = [ArgType(target, arg) for arg in args]
    name = LIBNAME * "_" * group * "_"
    name *= join((arg.puretype for arg in argtypes), "_")
    declare = ret * " " * name * "("
    declare *= join((arg.type * " " * arg.name for arg in argtypes), ", ")
    declare *= ")"
    prototype = declare * ";"
    FunctionDef(argtypes, purename, name, ret, declare, prototype)
end

function generate(;
    name::String,
    group,
    targets,
    args,
    operation,
    srcfile::Union{Nothing,IOStream}=nothing,
    testfile::Union{Nothing,IOStream}=nothing,
    headerfile::Union{Nothing,IOStream}=nothing
)
    for (target, ret) in targets
        func = FunctionDef(; purename=name, group, ret, target, args)
        code = Code(; declare=func.declare, operation, target)
        !isnothing(headerfile) && write(headerfile, func.prototype * "\n")
        !isnothing(srcfile) && write(srcfile, code.code * "\n")
    end
end

end # module
