using IntegLACore: generate

generate(
    name="axpy",
    group="blas",
    targets=[
        ("double", "void"),
        ("float", "void"),
        ("int32_t", "void"),
        ("int64_t", "void"),
    ],
    args=[("{target}", "{Val0}"), ("const {Vec}", "{Vec0}"), ("{Vec}", "{Vec1}")],
    operation="""
    for( {INT} i = 0; i < {Vec0}.size; i++){
        {Vec1}[i] += {Val0} * {Vec0};
    }
    """,
    srcfile=nothing,
    testfile=nothing,
    headerfile=nothing,
)
