package heat.ecs;

import haxe.ds.Either;

abstract EitherClassOrEnum<TClass, TEnum>(Either<Class<TClass>, Enum<TEnum>>) 
from Either<Class<TClass>, Enum<TEnum>>
to Either<Class<TClass>, Enum<TEnum>>
{
    @:from
    public static inline function fromClass<TClass>(cls:Class<TClass>):EitherClassOrEnum<TClass, Dynamic> {
        return Left(cls);
    }

    @:from
    public static inline function fromEnum<TEnum>(enm:Enum<TEnum>):EitherClassOrEnum<Dynamic, TEnum> {
        return Right(enm);
    }
}