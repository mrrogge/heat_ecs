package heat.ecs;

import haxe.ds.Either;
import haxe.ds.Option;

class World {
    public var lastIntId(default, null):Int = 0;

    var classComs = new Map<String, Map<EntityId, Dynamic>>();
    var enumComs = new Map<String, Map<EntityId, Dynamic>>();
    var dynComs = new Map<String, Map<EntityId, Dynamic>>();

    public function new() {

    }

    public function newId():EntityId {
        return ++lastIntId;
    }

    public function getClassComs<T>(cls:Class<T>)
    :haxe.ds.Option<Map<EntityId, T>> 
    {
        var name = Type.getClassName(cls);
        if (!classComs.exists(name)) return None;
        return Some(cast classComs[name]);
    }

    public function getClassCom<T>(cls:Class<T>, id:EntityId)
    :haxe.ds.Option<T>
    {
        var name = Type.getClassName(cls);
        if (!classComs.exists(name)) return None;
        if (!classComs[name].exists(id)) return None;
        return Some(classComs[name][id]);
    }

    public function getCom<T>(comType:EitherClassOrString<T>, id:EntityId):haxe.ds.Option<T> {
        return switch comType {
            case Left(cls): {
                this.getClassCom(cls, id);
            }
            case Right(s): {
                if (!dynComs.exists(s)) None;
                else if (!dynComs[s].exists(id)) None;
                else Some(dynComs[s][id]);
            }
        }
    }

    public function setClassCom<T>(cls:Class<T>, id:EntityId, com:T):World {
        var name = Type.getClassName(cls);
        if (!classComs.exists(name)) {
            classComs[name] = new Map<EntityId, T>();
        }
        classComs[name][id] = com;
        return this;
    }

    public function setDynCom(label:String, id:EntityId, com:Dynamic):World {
        if (!dynComs.exists(label)) {
            dynComs[label] = new Map<EntityId, Dynamic>();
        }
        dynComs[label][id] = com;
        return this;
    }
}

enum OneOfThree<T1,T2,T3> {
    ONE(one:T1);
    TWO(two:T2);
    THREE(three:T3);
}

abstract OneOfClassEnumOrString<TClass, TEnum>
(OneOfThree<Class<TClass>, Enum<TEnum>, String>)
from OneOfThree<Class<TClass>, Enum<TEnum>, String>
to OneOfThree<Class<TClass>, Enum<TEnum>, String>
{
    @:from
    inline public static function fromClass<TClass>(cls:Class<TClass>):OneOfClassEnumOrString<TClass, Dynamic> {
        return ONE(cls);
    }

    @:from
    inline public static function fromEnum<TEnum>(enm:Enum<TEnum>):OneOfClassEnumOrString<Dynamic, TEnum> {
        return TWO(enm);
    }

    @:from
    inline public static function fromString(s:String):OneOfClassEnumOrString<Dynamic, Dynamic> {
        return THREE(s);
    }
}

abstract EitherClassOrString<TClass>(haxe.ds.Either<Class<TClass>, String>) 
from haxe.ds.Either<Class<TClass>, String>
to haxe.ds.Either<Class<TClass>, String>
{
    @:from
    inline public static function fromClass<TClass>(cls:Class<TClass>):EitherClassOrString<TClass> {
        return haxe.ds.Either.Left(cls);
    }

    @:from
    inline public static function fromString<TClass>(s:String):EitherClassOrString<TClass> {
        return haxe.ds.Either.Right(s);
    }
}