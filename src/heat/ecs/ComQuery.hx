package heat.ecs;

class ComQuery {
    public var result(default, null) = new Array<EntityId>();

    var withMaps =  new Array<Map<EntityId, Any>>();
    var withoutMaps = new Array<Map<EntityId, Any>>();

    public function new() {

    }

    public function with(comMap:Map<EntityId, Any>):ComQuery {
        for (map in withMaps) {
            if (comMap == map) return this;
        }
        withMaps.push(comMap);
        return this;
    }

    public function without(comMap:Map<EntityId, Any>):ComQuery {
        for (map in withoutMaps) {
            if (comMap == map) return this;
        }
        withoutMaps.push(comMap);
        return this;
    }

    public function run():ComQuery {
        while (result.length > 0) result.pop();
        var firstMap = withMaps[0];
        if (firstMap == null) return this;
        for (id => _ in firstMap) {
            var hasAllRequiredComs = true;
            for (map in withMaps) {
                if (map == firstMap) continue;
                if (!map.exists(id)) {
                    hasAllRequiredComs = false;
                    break;
                }
            }
            if (!hasAllRequiredComs) continue;
            var hasNoDisallowedComs = true;
            for (map in withoutMaps) {
                if (map.exists(id)) {
                    hasNoDisallowedComs = false;
                    break;
                }
            }
            if (!hasNoDisallowedComs) continue;
            result.push(id);
        }
        return this;
    }

    public inline function iter():Iterator<EntityId> {
        run();
        return result.iterator();
    }

    public function checkId(id:EntityId):Bool {
        for (map in withMaps) {
            if (!map.exists(id)) return false;
        }
        for (map  in withoutMaps) {
            if (map.exists(id)) return false;
        }
        return true;
    }
}