package heat.ecs;

/**
    An interface for a map of `EntityId`s to component instances.
**/
interface IComMap<T> {
    /**
        Returns the component instance for a given `id`.
        @param id The `EntityId` key.
    **/
    public function get(id:EntityId):T;

    public function set(id:EntityId, com:T):Void;

    /**
        Returns `true` if a component instance exists for `id`, otherwise `false`.
        @param id The `EntityId` key.
    **/
    public function exists(id:EntityId):Bool;

    /**
        Return an iterator over the `EntityId` keys in this map. The order is undefined.
    **/
    public function keys():Iterator<EntityId>;
}