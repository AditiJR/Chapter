enum AvatarTone { yellow, peach, pink }

/// A stable avatar colour per user, so the same person always looks the same.
AvatarTone toneFor(String uid) =>
    AvatarTone.values[uid.codeUnits.fold(0, (a, b) => a + b) %
        AvatarTone.values.length];
