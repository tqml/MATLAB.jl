# exceptions
struct MEngineError <: Exception
    message::String
end



struct MatFileException <: Exception
    message::String
end