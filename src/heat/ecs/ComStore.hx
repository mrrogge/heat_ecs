package heat.ecs;

/**
    Underlying type for `ComStore`. Included here for completeness; there is no need to use this class directly.
**/
class ComStoreInternal<TCom, TData> implements IComMap<TCom> {
    var map = new ComMap<TCom>();
    var pool:Pool<TCom, TData>;

    /**
        Constructs a new instance. 

        @param constructor a method that builds and returns a new `TCom` instance when called. See `Pool`.
        @param init a method that initializes a `TCom` instance when called. See `Pool`.
    **/
    public function new(constructor:(?data:TData)->TCom, 
    ?init:(instance:TCom, ?data:TData)->Void) {
        pool = new Pool<TCom, TData>(constructor, init);
    }

    /**
        Adds a component for an entity.

        If no component currently exists, an instance will be mapped to the `EntityId`. Otherwise, if the entity already has a component instance, the component will be initialized using the `data` parameter.
    **/
    public function add(id:EntityId, ?data:TData):TCom {
        if (map.exists(id)) {
            pool._init(map[id], data);
        }
        else {
            map[id] = pool.get(data);
        }
        return map[id];
    }

    /**
        Removes a component from an entity.

        The instance is returned to the internal `Pool`, so make sure not to reference the instance once removed, otherwise conflicts may occur.
    **/
    public function remove(id:EntityId) {
        if (map.exists(id)) {
            pool.put(map[id]);
            map[id] = null;
        }
    }

    @:inheritDoc(IComMap.get)
    public function get(id:EntityId):TCom {
        return map[id];
    }

    @:inheritDoc(IComMap.set)
    public function set(id:EntityId, com:TCom):Void {
        map.set(id, com);
    }

    @:inheritDoc(IComMap.exists)
    public function exists(id:EntityId):Bool {
        return map[id] != null;
    }

    @:inheritDoc(IComMap.keys)
    public function keys():Iterator<EntityId> {
        return map.keys();
    }

    /**
        Flushes the internal pool, removing all old component instances. Components currently mapped to entities are unaffected.
    **/
    public function flush() {
        pool.flush();
    }
}

/**
    A wrapper around a `ComMap` and a corresponding `Pool`. This provides a nice way to manage components while automatically reusing old instances. Because this class implements `IComMap`, it can be passed to a `ComQuery` like any other `ComMap`.
**/
@:forward
@:forward.new
abstract ComStore<TCom, TData>(ComStoreInternal<TCom, TData>)
from ComStoreInternal<TCom, TData>
to ComStoreInternal<TCom, TData> {
    @:arrayAccess
    public inline function getCom(id:EntityId):TCom {
        return this.get(id);
    }

    @:arrayAccess
    public inline function setCom(id:EntityId, com:TCom):Void {
        return this.set(id, com);
    }
}