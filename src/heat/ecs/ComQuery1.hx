package heat.ecs;

import haxe.ds.Either;

/**
    An implementation of `IComQuery` for a single `ComMap`.
**/
class ComQuery1<T0> implements IComQuery {

    public var map0(default, null):IComMap<T0>;

    @:inheritDoc(IComQuery.result)
    public var result(default, null) = new Array<EntityId>();

    public function new(map0:IComMap<T0>) {
        this.map0 = map0;
    }

    @:inheritDoc(IComQuery.run)
    public function run():Array<EntityId> {
        while (result.length > 0) result.pop();
        for (id in map0.keys()) {
            result.push(id);
        }
        return this.result;
    }

    @:inheritDoc(IComQuery.hasAll)
    public function hasAll(id:EntityId):Bool {
        return this.map0.exists(id);
    }

    /**
        Returns a `Tuple1` of a component for a given `id` corresponding to the query's `ComMap`. The component may be null if it does not exist for `id`.

        If a `tuple` argument is passed, the component will be applied to that instance and returned. Otherwise, a new `Tuple1` instance will be constructed and returned.

        @param id The entity identifier to check.

        @param tuple An existing tuple to reuse, if desired.
    **/
    public function getComTuple(id:EntityId, ?tuple:Tuple1<T0>):Tuple1<T0> {
        var returnedTuple = {
            if (tuple != null) tuple
            else new Tuple1();
        };
        returnedTuple.e0 = this.map0.get(id);
        return returnedTuple;
    }
}