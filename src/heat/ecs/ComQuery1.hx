package heat.ecs;

/**
    An implementation of `IComQuery` for a single `ComMap`.
**/
class ComQuery1<T0> implements IComQuery {

    public var map0(default, null):Map<EntityId, T0>;

    @:inheritDoc(IComQuery.result)
    public var result(default, null) = new Array<EntityId>();

    public function new(map0:Map<EntityId, T0>) {
        this.map0 = map0;
    }

    @:inheritDoc(IComQuery.run)
    public function run():Array<EntityId> {
        while (result.length > 0) result.pop();
        for (id => val in map0) {
            result.push(id);
        }
        return this.result;
    }

    @:inheritDoc(IComQuery.hasAll)
    public function hasAll(id:EntityId):Bool {
        return this.map0.exists(id);
    }
}