using Google.Cloud.Firestore;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateSlimBuilder(args);

// Configure Native AOT JSON source generation for safe runtime serialization
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.TypeInfoResolverChain.Insert(0, AppJsonContext.Default);
});

// Configure CORS for your future Vercel Frontend
var allowAngularApp = "_allowAngularApp";
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: allowAngularApp,
        policy =>
        {
            policy.AllowAnyOrigin() // Allows any frontend to connect for now
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

var app = builder.Build();
app.UseCors(allowAngularApp);

// Test Endpoint fetching documents from Firestore
app.MapGet("/api/tasks", async () =>
{
    string projectId = Environment.GetEnvironmentVariable("GOOGLE_CLOUD_PROJECT") ?? "my-native-aot-app";
    FirestoreDb db = await FirestoreDb.CreateAsync(projectId);

    CollectionReference collection = db.Collection("tasks");
    QuerySnapshot snapshot = await collection.GetSnapshotAsync();

    var taskList = new List<TaskDocument>();
    foreach (DocumentSnapshot document in snapshot.Documents)
    {
        if (document.Exists)
        {
            taskList.Add(document.ConvertTo<TaskDocument>());
        }
    }
    return taskList;
});

app.Run();

[FirestoreData]
public class TaskDocument
{
    [FirestoreProperty]
    public string Title { get; set; } = string.Empty;

    [FirestoreProperty]
    public bool IsCompleted { get; set; }
}

[JsonSerializable(typeof(List<TaskDocument>))]
internal partial class AppJsonContext : JsonSerializerContext { }