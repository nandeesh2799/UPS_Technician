// GENERATED — do not edit manually
import 'package:hive/hive.dart';

class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override final int typeId = 20;
  @override DateTime read(BinaryReader reader) =>
    DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  @override void write(BinaryWriter writer, DateTime obj) =>
    writer.writeInt(obj.millisecondsSinceEpoch);
}

class NullableDateTimeAdapter extends TypeAdapter<DateTime?> {
  @override final int typeId = 21;
  @override DateTime? read(BinaryReader reader) {
    final has = reader.readBool();
    if (!has) return null;
    return DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  }
  @override void write(BinaryWriter writer, DateTime? obj) {
    writer.writeBool(obj != null);
    if (obj != null) writer.writeInt(obj.millisecondsSinceEpoch);
  }
}
