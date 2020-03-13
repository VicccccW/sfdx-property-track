public class Queueable_UpsertImportProperty implements Queueable {
    public List<PropertyWrapper> properties;

    public Queueable_UpsertImportProperty(List<PropertyWrapper> properties) {
        this.properties = properties;
    }

    public void execute(QueueableContext context) {
        PropertyController.insertProperty(properties);
    }
}
