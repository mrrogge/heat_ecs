package heat.ecs;

/**
    A mutable tuple structure with two elements.
**/
@:expose("Tuple2")
class Tuple2<T0, T1> {
    /** Element 0.**/
    public var e0:T0;
    /** Element 1.**/
    public var e1:T1;

    /**
        @param e0 Element 0.
        @param e1 Element 1.
    **/
    public function new(?e0:T0, ?e1:T1) {
        this.init(e0, e1);
    }

    /**
        @param e0 Element 0.
        @param e1 Element 1.
    **/   
    public inline function init(?e0:T0, ?e1:T1) {
        this.e0 = e0;
        this.e1 = e1;
    }
}