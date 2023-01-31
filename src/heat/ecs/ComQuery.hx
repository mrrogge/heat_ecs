package heat.ecs;

class ComQuery {
    public final result = new Array<EntityId>();

    final withMapArray =  new Array<Map<EntityId, Any>>();
    final withMaps = new Map<Map<EntityId, Any>, Bool>();
    final withoutMapArray = new Array<Map<EntityId, Any>>();
    final withoutMaps = new Map<Map<EntityId, Any>, Bool>();

    public function new() {

    }

    public function with(comMap:Map<EntityId, Any>):ComQuery {
        if (withMaps.exists(comMap)) return this;
        withMaps[comMap] = true;
        withMapArray.push(comMap);
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