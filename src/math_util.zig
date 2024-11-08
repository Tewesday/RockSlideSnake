
pub fn clamp(min: i8, value: i8) i8 {
    if (value < min) {
        return min;
    }
    return value;
}