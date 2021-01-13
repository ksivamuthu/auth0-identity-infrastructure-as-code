import * as pulumi from "@pulumi/pulumi";
import * as auth0 from "@pulumi/auth0";

const client = new auth0.Client("auth0-pulumi-demo", {
    name: "auth0-pulumi-demo",
    appType: "spa",
    allowedLogoutUrls: ["https://auth0pulumiapp-dev.azurewebsites.net"],
    allowedOrigins: ["https://auth0pulumiapp-dev.azurewebsites.net"],
    webOrigins: ["https://auth0pulumiapp-dev.azurewebsites.net"]
});

export const clientId = client.clientId;