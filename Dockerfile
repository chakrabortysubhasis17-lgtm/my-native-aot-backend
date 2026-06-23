# Stage 1: Install build dependencies and compile native binary with .NET 10
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
RUN apt-get update && apt-get install -y clang zlib1g-dev
WORKDIR /src

# Copy and restore project files
COPY ["MyNativeAotApp.csproj", "./"]
RUN dotnet restore

# Copy remaining source code and publish
COPY . .
RUN dotnet publish -c Release -r linux-x64 -o /app /p:PublishAot=true

# Stage 2: Standard lightweight .NET 10 runtime container
FROM mcr.microsoft.com/dotnet/runtime-deps:10.0 AS final
WORKDIR /app
COPY --from=build /app .
EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080
ENTRYPOINT ["./MyNativeAotApp"]