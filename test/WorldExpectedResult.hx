/*
This is an example of what the WorldBuilder macros should produce.

Given a class that implements IWorld, we should expect to see the following additional types:
* an enum called ComLabel_<Class>
* an enum called ComOptionImpl_<Class>
* an abstract over ComOptionImpl_<Class>, called ComOption_<Class>

The <Class> should be replaced with a unique string representation of the class implementing IWorld. These additional types should be added to the module that contains the class.

When types are registered for components, the build macro will modify the class as well as the companion types mentioned above. These changes will allow components to be accessed for entity IDs in a type-safe way.
*/

/**
    Let's define some test components to demonstrate what our result should be:
**/
private class TestClass {
    public function new() {}
}

private typedef TestStruct = {x:Float, y:Float}

/**
    When our class implements IWorld, it should look something like this:
**/
private class TestWorld1 {   // implements IWorld
    //constructor is left unspecified by IWorld

    public function getCom(id:heat.ecs.EntityId, label:ComLabel_TestWorld1):haxe.ds.Option<ComOption_TestWorld1> {
        return switch label {
            default: None;
        }
    }

    public function setCom(id:heat.ecs.EntityId, com:ComOption_TestWorld1) {
        switch com {
            default: {}
        }
    }

    public function buildQuery():EntityQuery_TestWorld1 {
        return new EntityQuery_TestWorld1(this);
    }
}

/**
    The companion types resulting from the implement of IWorld should look like the following:
**/
private enum ComLabel_TestWorld1 {

}

private enum ComOptionImpl_TestWorld1 {

}

private abstract ComOption_TestWorld1(ComOptionImpl_TestWorld1) 
from ComOptionImpl_TestWorld1
to ComOptionImpl_TestWorld1
{

}

private class EntityQuery_TestWorld1 {
    var withLabels = new Array<ComLabel_TestWorld1>();
    var withLabelMap = new Map<ComLabel_TestWorld1, Bool>();
    var world:TestWorld1;

    public function new(world:TestWorld1) {
        this.world = world;
    }

    public function with(label:ComLabel_TestWorld1):EntityQuery_TestWorld1 {
        if (withLabelMap.exists(label)) return this;
        withLabelMap[label] = true;
        withLabels.push(label);
        return this;
    }

    
}

/**
    Now lets say we apply the following build macros on TestWorld:
     
    @:build(heat.ecs.WorldBuilder.registerComType(new TestClass))
    @:build(heat.ecs.WorldBuilder.registerComType({x:1, y:2}, "POINT"))

    Each of these should modify the types so that those components can be stored in maps of EntityIds. The getCom() and setCom() methods should be altered with logic that points to the right map for the right component type.

    The 2nd param in the build macro is for the label. This determines what the ComLabel enum constructor should be named for each component. It does not have to be specified; if left out, a default label of T<N> will be used, where <N> is some number unique for each type.

    Here is what our types should look like once the macros are processed:
**/
private class TestWorld2 {   // implements IWorld
    //constructor is left unspecified by IWorld

    var _comMap_T0 = new Map<heat.ecs.EntityId, TestClass>();
    var _comMap_POINT = new Map<heat.ecs.EntityId, TestStruct>();

    public function getCom(id:heat.ecs.EntityId, label:ComLabel_TestWorld2):haxe.ds.Option<ComOption_TestWorld2> {
        return switch label {
            case T0: _comMap_T0[id] == null ? None : Some(_comMap_T0[id]);
            case POINT: _comMap_POINT[id] == null ? None : Some(_comMap_POINT[id]);
            default: None;
        }
    }

    public function setCom(id:heat.ecs.EntityId, com:ComOption_TestWorld2) {
        switch com {
            case T0(com): _comMap_T0[id] = com;
            case POINT(com): _comMap_POINT[id] = com;
            default: {}
        }
    }
}

/**
    The companion types resulting from the implement of IWorld should look like the following:
**/
private enum ComLabel_TestWorld2 {
    T0;
    POINT;
}

private enum ComOptionImpl_TestWorld2 {
    T0(com:TestClass);
    POINT(com:TestStruct);
}

private abstract ComOption_TestWorld2(ComOptionImpl_TestWorld2) 
from ComOptionImpl_TestWorld2
to ComOptionImpl_TestWorld2 
{
    @:from
    inline public static function fromT0(com:TestClass):ComOption_TestWorld2 {
        return ComOptionImpl_TestWorld2.T0(com);
    }

    @:from
    inline public static function fromPOINT(com:TestStruct):ComOption_TestWorld2 {
        return ComOptionImpl_TestWorld2.POINT(com);
    }

    @:to
    inline public function toT0():TestClass {
        return switch (this) {
            case T0(com): com;
            default: null;
        }
    }

    @:to
    inline public function toPOINT():TestStruct {
        return switch (this) {
            case POINT(com): com;
            default: null;
        }
    }
}