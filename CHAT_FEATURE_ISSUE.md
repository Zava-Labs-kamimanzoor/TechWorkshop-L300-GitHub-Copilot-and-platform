# Add Chat Functionality with Microsoft Foundry Phi4 Integration

## Feature Description
Add a simple chat functionality as a separate page that integrates with Microsoft Foundry's Phi4 model endpoint to provide AI-powered chat responses.

## Requirements

### Infrastructure Changes (✅ Completed)
- [x] Update Foundry Bicep module to deploy Phi4 model
- [x] Add Phi4 deployment name as environment variable
- [x] Configure role assignment for App Service to access Foundry endpoint
- [x] Deploy infrastructure using `azd up`

### Application Features
- [ ] Create a new Chat page/view in the ASP.NET application
- [ ] Add a ChatController to handle chat requests
- [ ] Implement a service to communicate with the Foundry Phi4 endpoint
- [ ] Create a user interface with:
  - Text input field for user messages
  - Submit button to send messages
  - Text area to display chat history (user messages + AI responses)
  - Clear/reset functionality

### Technical Implementation Details

#### Backend Implementation
1. **Create ChatService.cs** in the `Services` folder:
   - Initialize Azure OpenAI client using managed identity authentication
   - Read configuration from environment variables:
     - `FOUNDRY_ENDPOINT`: The Foundry service endpoint
     - `FOUNDRY_PHI4_DEPLOYMENT_NAME`: The Phi4 deployment name (default: "phi4")
   - Implement method to send messages to Phi4 and return responses
   - Handle errors gracefully

2. **Create ChatController.cs** in the `Controllers` folder:
   - Add action to display the chat page
   - Add POST endpoint to send messages to ChatService
   - Return JSON response with AI-generated text

3. **Update appsettings.json**:
   ```json
   {
     "FoundrySettings": {
       "Endpoint": "",
       "Phi4DeploymentName": "phi4"
     }
   }
   ```

4. **Update Program.cs**:
   - Register ChatService in dependency injection
   - Configure Azure OpenAI client with managed identity

#### Frontend Implementation
1. **Create Chat/Index.cshtml** view:
   - Simple, clean UI with Bootstrap styling
   - Form with text input and submit button
   - Text area to display conversation history
   - JavaScript to handle form submission via AJAX
   - Auto-scroll to latest messages

### Dependencies
- Add NuGet package: `Azure.AI.OpenAI` (latest version)
- Add NuGet package: `Azure.Identity` (for managed identity authentication)

### Configuration
The following environment variables are already configured in the infrastructure:
- `FOUNDRY_ENDPOINT`: Automatically set by Bicep deployment
- `FOUNDRY_PHI4_DEPLOYMENT_NAME`: Automatically set to "phi4"

### Testing Checklist
- [ ] Verify infrastructure deployment completes successfully
- [ ] Verify App Service has access to Foundry endpoint (check role assignments)
- [ ] Test chat page loads correctly
- [ ] Test sending a message returns a response from Phi4
- [ ] Test error handling for network failures
- [ ] Test UI responsiveness on different screen sizes
- [ ] Verify conversation history displays correctly

### Deployment Steps
1. Deploy infrastructure with Phi4 model:
   ```bash
   azd up
   ```

2. Add required NuGet packages to the project

3. Implement backend services and controllers

4. Create frontend views and JavaScript

5. Build and deploy the application:
   ```bash
   azd deploy
   ```

### Acceptance Criteria
- ✅ Infrastructure deployed with Foundry and Phi4 model
- ✅ App Service has proper permissions to access Foundry
- Chat page is accessible from the navigation menu
- Users can type messages and receive AI-generated responses
- Conversation history is displayed in a text area
- Error messages are shown when the service is unavailable
- The UI is responsive and user-friendly

### Notes
- The infrastructure changes have been completed and committed
- Use Azure Managed Identity for authentication (no API keys required)
- Phi4 model version: 2024-12-12
- Deployment capacity: 10 (Standard tier)

### Related Files
- Infrastructure: `infra/modules/foundry.bicep`, `infra/main.bicep`, `infra/modules/appservice.bicep`
- Application: To be created in `src/` directory

### Labels
- enhancement
- feature
