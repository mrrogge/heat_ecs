package heat.ecs;

import haxe.ds.Either;

/**
    An identifier for an entity.
**/
abstract EntityId(Either<String, Int>) from Either<String, Int> 
to Either<String, Int> {
    @:from
    inline public static function fromString(s:String):EntityId {
        return Left(s);
    }

    @:from
    inline public static function fromInt(i:Int):EntityId {
        return Right(i);
    }

    @:to
    inline public function toString():String {
        return switch (this) {
            case Left(s): 'ID("$s")';
            case Right(i): 'ID($i)';
        }
    }

    @:op(a == b) public static inline function eq(a:EntityId, b:EntityId):Bool {
        return switch a {
            case Left(a): switch b {
                case Left(b): a == b;
                case Right(b): false;
            }
            case Right(a): switch b{
                case Left(b): false;
                case Right(b): a == b;
            }
        }
    }

    @:op(a != b) public static inline function neq(a:EntityId, b:EntityId):Bool {
        return !eq(a, b);
    }

    //For the comparison operators, we need to define how int IDs relate to string IDs. We will use the convention that all int values are less than all string values.
    
    @:op(a < b) public static inline function less(a:EntityId, b:EntityId):Bool {
        return switch a {
            case Left(a): switch b {
                case Left(b): a < b;
                case Right(b): false;
            }
            case Right(a): switch b {
                case Left(b): true;
                case Right(b): a < b;
            }
        }
    }

    @:op(a <= b) public static inline function leq(a:EntityId, b:EntityId):Bool {
        return switch a {
            case Left(a): switch b {
                case Left(b): a <= b;
                case Right(b): false;
            }
            case Right(a): switch b {
                case Left(b): true;
                case Right(b): a <= b;
            }
        }
    }

    @:op(a > b) public static inline function grt(a:EntityId, b:EntityId):Bool {
        return switch a {
            case Left(a): switch b {
                case Left(b): a > b;
                case Right(b): true;
            }
            case Right(a): switch b {
                case Left(b): false;
                case Right(b): a > b;
            }
        }
    }

    @:op(a >= b) public static inline function geq(a:EntityId, b:EntityId):Bool {
        return switch a {
            case Left(a): switch b {
                case Left(b): a >= b;
                case Right(b): true;
            }
            case Right(a): switch b {
                case Left(b): false;
                case Right(b): a >= b;
            }
        }
    }
}