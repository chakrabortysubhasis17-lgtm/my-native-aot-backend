# Stage 1: Standard high-performance .NET 10 compilation
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy and restore project tracking files
COPY ["MyNativeAotApp.csproj", "./"]
RUN dotnet restore

# Copy remaining source code and publish as a standard deployment
COPY . .
RUN dotnet publish -c Release -o /app

# Stage 2: Light web runtime container
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app .
EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080
ENTRYPOINT ["dotnet", "MyNativeAotApp.dll"]