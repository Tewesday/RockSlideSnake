pub const GamePhaseEnum = enum {
    Preload,
    OnLoad,
    PostLoad,
    PreInput,
    OnInput,
    PostInput,
    PreUpdate,
    OnUpdate,
    PostUpdate,
    PreStore,
    OnStore,
};

pub const GamePhase = struct {
   currentPhase: GamePhaseEnum,
};

pub const MatchPhaseEnum = enum {
    Starting,
    Active,
    Paused,
    Victory,
    Defeat,
};

pub const MatchPhase = struct {
    currentPhase: MatchPhaseEnum,
};
