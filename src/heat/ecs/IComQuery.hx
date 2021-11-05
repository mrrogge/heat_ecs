package heat.ecs;

/**
    Interface for component queries. These are used to find all the `EntityId`s that currently have a set of specific components.

    Implementations of `IComQuery` will typically accept `ComMap` instances in their constructors. They then populate an array with all the `EntityId`s that exist for all of those `ComMap` instances. This array is reused, so re-running the query in an update loop will not create junk instances each frame.
**/
interface IComQuery {
    /**
        After calling run(), this will contain every `EntityId` that is found for all `ComMap`s. The order of elements is undefined.
    **/
    public var result(default, null):Array<EntityId>;

    /**
        Updates the `result` array.
    **/
    public function run():Array<EntityId>;

    /**
        Returns true if the `id` has instances of all components defined for this query (otherwise false).
    **/
    public function hasAll(id:EntityId):Bool;
}