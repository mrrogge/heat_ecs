package heat.ecs;

class ComQuery {
    public final result = new Array<EntityId>();

    final withMapArray =  new Array<Map<EntityId, Any>>();
    final withMaps = new Map<haxe.ds.IntMap<Any>, Bool>();
    final withoutMapArray = new Array<Map<EntityId, Any>>();
    final withoutMaps = new Map<haxe.ds.IntMap<Any>, Bool>();

    final withEqualCondArray = new Array<WhereEqualToCondition<Any>>();
    final withEqualCondMap = new Map<haxe.ds.IntMap<Any>, WhereEqualToCondition<Any>>();

    final condArray = new Array<Condition>();

    public function new() {

    }

    public function with(comMap:Map<EntityId, Any>):ComQuery {
        condArray.push(new WithCondition(comMap));
        return this;
    }

    @:generic
    public function whereEqualTo<T>(comMap:Map<EntityId, T>, value:T):ComQuery {
        condArray.push(new WhereEqualToCondition(comMap, value));
        return this;
    }

    public function without(comMap:Map<EntityId, Any>):ComQuery {
        condArray.push(new WithoutCondition(comMap));
        return this;
    }

    @:generic
    public function whereNotEqualTo<T>(comMap:Map<EntityId, T>, value:T):ComQuery {
        condArray.push(new WhereNotEqualToCondition(comMap, value));
        return this;
    }

    public function run():ComQuery {
        while (result.length > 0) result.pop();

        var firstMap:Null<ComMap<Any>> = null;
        for (cond in condArray) {
            var whereEqualToCond:WhereEqualToCondition<Any> = Std.downcast(
                cond, WhereEqualToCondition);
            if (whereEqualToCond != null) {
                firstMap = whereEqualToCond.comMap;
                break;
            }
            var withCond = Std.downcast(cond, WithCondition);
            if (withCond != null) {
                firstMap = withCond.comMap;
                break;
            }
        }

        if (firstMap == null) return this;

        for (id => _ in firstMap) {
            var satisfiesAllConds = true;
            for (cond in condArray) {
                satisfiesAllConds = satisfiesAllConds && cond.check(id);
                if (!satisfiesAllConds) break;
            }
            if (!satisfiesAllConds) continue;
            result.push(id);
        }

        return this;
    }

    public inline function iter():Iterator<EntityId> {
        run();
        return result.iterator();
    }

    public function checkId(id:EntityId):Bool {
        for (map in withMapArray) {
            if (!map.exists(id)) return false;
        }
        for (map  in withoutMapArray) {
            if (map.exists(id)) return false;
        }
        return true;
    }
}

private abstract class Condition {
    public abstract function check(id:EntityId):Bool;
}

private class WithCondition extends Condition {
    public final comMap:Map<EntityId, Any>;
    
    public function new(comMap:Map<EntityId, Any>) {
        this.comMap = comMap;
    }

    public function check(id:EntityId):Bool {
        return comMap.exists(id);
    }
}

private class WithoutCondition extends Condition {
    public final comMap:Map<EntityId, Any>;
    
    public function new(comMap:Map<EntityId, Any>) {
        this.comMap = comMap;
    }

    public function check(id:EntityId):Bool {
        return !comMap.exists(id);
    }
}

private class WhereEqualToCondition<T> extends Condition {
    public final comMap:Map<EntityId, T>;
    public final value:T;
    
    public function new(comMap:Map<EntityId, T>, value:T) {
        this.comMap = comMap;
        this.value = value;
    }

    public function check(id:EntityId):Bool {
        return comMap.exists(id) && comMap[id] == value;
    }
}

private class WhereNotEqualToCondition<T> extends Condition {
    public final comMap:Map<EntityId, T>;
    public final value:T;
    
    public function new(comMap:Map<EntityId, T>, value:T) {
        this.comMap = comMap;
        this.value = value;
    }

    public function check(id:EntityId):Bool {
        return !comMap.exists(id) || comMap[id] != value;
    }
}