
// Import your ItemModel class

/*class ItemModelAdapter extends TypeAdapter<ItemModel> {
  @override
  final int typeId = 1; // Use a unique typeId for each HiveType

  @override
  ItemModel read(BinaryReader reader) {
    return ItemModel(
      id: reader.readInt(),
      name: reader.readString(),
      description: reader.readString(),
      price: reader.readInt(),
      image: reader.readString(),
      watermarkimage: reader.read(),
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
      address: reader.readString(),
      contact: reader.readString(),
      totalLikes: reader.readInt(),
      views: reader.readInt(),
      type: reader.readString(),
      status: reader.readString(),
      active: reader.readBool(),
      videoLink: reader.readString(),
      user: reader.read() as User?,
      // Assuming User is a HiveObject
      galleryImages: reader.readList() as List<GalleryImages>?,
      // Assuming GalleryImages is a List
      category: reader.read() as CategoryModel?,
      // Assuming CategoryModel is a HiveObject
      customFields: reader.readList() as List<CustomFieldModel>?,
      // Assuming CustomFieldModel is a List
      isLike: reader.readBool(),
      isFeature: reader.readBool(),
      created: reader.readString(),
      itemType: reader.readString(),
      userId: reader.readInt(),
      categoryId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ItemModel obj) {
    writer.writeInt(obj.id!);
    writer.writeString(obj.name!);
    writer.writeString(obj.description!);
    writer.writeInt(obj.price!);
    writer.writeString(obj.image!);
    writer.write(obj.watermarkimage);
    writer.writeDouble(obj.latitude!);
    writer.writeDouble(obj.longitude!);
    writer.writeString(obj.address!);
    writer.writeString(obj.contact!);
    writer.writeInt(obj.totalLikes!);
    writer.writeInt(obj.views!);
    writer.writeString(obj.type!);
    writer.writeString(obj.status!);
    writer.writeBool(obj.active!);
    writer.writeString(obj.videoLink!);
    writer.write(obj.user); // Assuming User is a HiveObject
    writer.writeList(obj.galleryImages!); // Assuming GalleryImages is a List
    writer.write(obj.category); // Assuming CategoryModel is a HiveObject
    writer.writeList(obj.customFields!); // Assuming CustomFieldModel is a List
    writer.writeBool(obj.isLike!);
    writer.writeBool(obj.isFeature!);
    writer.writeString(obj.created!);
    writer.writeString(obj.itemType!);
    writer.writeInt(obj.userId!);
    writer.writeInt(obj.categoryId!);
  }
}*/
