package heat.ecs;

class ComQuery {
    public var result(default, null) = new Array<EntityId>();

    var withMapArray =  new Array<Map<EntityId, Any>>();
    var withMaps = new Map<Map<EntityId, Any>, Bool>();
    var withoutMapArray = new Array<Map<EntityId, Any>>();
    var withoutMaps = new Map<Map<EntityId, Any>, Bool>();

    public function new() {

    }

    public function with(comMap:Map<EntityId, Any>):ComQuery {
        for (map in withMapArray) {
            if (comMap == map) return this;
        }
        withMapArray.push(comMap);
        return this;
    }

    public function without(comMap:Map<EntityId, Any>):ComQuery {
        for (map in withoutMapArray) {
            if (comMap == map) return this;
        }
        withoutMapArray.push(comMap);
        return this;
    }

    public function run():ComQuery {
        while (result.length > 0) result.pop();
        var firstMap = withMapArray[0];
        if (firstMap == null) return this;
        for (id => _ in firstMap) {
            var hasAllRequiredComs = true;
            for (map in withMapArray) {
                if (map == firstMap) continue;
                if (!map.exists(id)) {
                    hasAllRequiredComs = false;
                    break;
                }
            }
            if (!hasAllRequiredComs) continue;
            var hasNoDisallowedComs = true;
            for (map in withoutMapArray) {
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
        for (map in withMapArray) {
            if (!map.exists(id)) return false;
        }
        for (map  in withoutMapArray) {
            if (map.exists(id)) return false;
        }
        return true;
    }
}