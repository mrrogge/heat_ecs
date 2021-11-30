package heat.ecs;

/**
    A mutable tuple structure with three elements.
**/
@:expose("Tuple3")
class Tuple3<T0, T1, T2> {
    /** Element 0.**/
    public var e0:T0;
    /** Element 1.**/
    public var e1:T1;
    /** Element 2.**/
    public var e2:T2;

    /**
        @param e0 Element 0.
        @param e1 Element 1.
        @param e2 Element 2.
    **/
    public function new(?e0:T0, ?e1:T1, ?e2:T2) {
        this.init(e0, e1, e2);
    }

    /**
        @param e0 Element 0.
        @param e1 Element 1.
        @param e2 Element 2.
    **/   
    public inline function init(?e0:T0, ?e1:T1, ?e2:T2) {
        this.e0 = e0;
        this.e1 = e1;
        this.e2 = e2;
    }
}