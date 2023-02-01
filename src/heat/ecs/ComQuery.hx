package heat.ecs;

class ComQuery {
    public final result = new Array<EntityId>();

    final withMapArray =  new Array<Map<EntityId, Any>>();
    final withMaps = new Map<haxe.ds.IntMap<Any>, Bool>();
    final withoutMapArray = new Array<Map<EntityId, Any>>();
    final withoutMaps = new Map<haxe.ds.IntMap<Any>, Bool>();

    final withEqualCondArray = new Array<WhereEqualToCondition<Any>>();
    final withEqualCondMap = new Map<haxe.ds.IntMap<Any>, WhereEqualToCondition<Any>>();

    public function new() {

    }

    public function with(comMap:Map<EntityId, Any>):ComQuery {
        if (withMaps.exists(comMap)) return this;
        withMaps[comMap] = true;
        withMapArray.push(comMap);
        return this;
    }

    @:generic
    public function withEqual<T>(comMap:Map<EntityId, T>, value:T):ComQuery {
        with(comMap);
        if (withEqualCondMap.exists(comMap)) {
            withEqualCondMap[comMap].value = value;
        }
        else {
            withEqualCondMap[comMap] = new WhereEqualToCondition(comMap, value);
            withEqualCondArray.push(withEqualCondMap[comMap]);
        }
        return this;
    }

    public function without(comMap:Map<EntityId, Any>):ComQuery {
        if (withoutMaps.exists(comMap)) return this;
        withoutMaps[comMap] = true;
        withoutMapArray.push(comMap);
        return this;
    }

    public function run():ComQuery {
        while (result.length > 0) result.pop();
        var firstMap = withMapArray[0];
        if (firstMap == null) return this;
        for (id => _ in firstMap) {
            // check against all "with" conditions
            var hasAllRequiredComs = true;
            for (map in withMapArray) {
                if (map == firstMap) continue;
                if (!map.exists(id)) {
                    hasAllRequiredComs = false;
                    break;
                }
            }
            if (!hasAllRequiredComs) continue;

            // check against all "without" conditions
            var hasNoDisallowedComs = true;
            for (map in withoutMapArray) {
                if (map.exists(id)) {
                    hasNoDisallowedComs = false;
                    break;
                }
            }
            if (!hasNoDisallowedComs) continue;

            // check against all "withEqual" conditions
            var hasAllRequiredComVals = true;
            for (cond in withEqualCondArray) {
                hasAllRequiredComVals = hasAllRequiredComVals && cond.check(id);
                if (!hasAllRequiredComVals) break;
            }
            if (!hasAllRequiredComVals) continue;

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