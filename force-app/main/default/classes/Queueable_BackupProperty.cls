public class Queueable_BackupProperty implements Queueable, Database.AllowsCallouts {

    public Queueable_BackupProperty() {

    }

    public void execute(QueueableContext context) {
        BackupProperty.sendBackupRequest();
    }
}