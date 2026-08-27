using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using Microsoft.Extensions.Logging;

namespace HistoClassAI.Api.Services;

public interface IEmailService
{
    Task SendEmailAsync(string toEmail, string subject, string body);
}

public class EmailService : IEmailService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendEmailAsync(string toEmail, string subject, string body)
    {
        var smtpSettings = _configuration.GetSection("SmtpSettings");

        var host = smtpSettings["Host"];
        var portStr = smtpSettings["Port"];
        var username = smtpSettings["Username"];
        var password = smtpSettings["Password"];
        var senderName = smtpSettings["SenderName"] ?? "HistoClassAI";
        var senderEmail = smtpSettings["SenderEmail"] ?? username;

        if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(username))
        {
            _logger.LogWarning("Les paramètres SMTP ne sont pas totalement configurés.");
            throw new InvalidOperationException("Paramètres SMTP non configurés.");
        }

        int port = int.TryParse(portStr, out var p) ? p : 587;

        var email = new MimeMessage();
        email.From.Add(new MailboxAddress(senderName, senderEmail));
        email.To.Add(new MailboxAddress("", toEmail));
        email.Subject = subject;

        var bodyBuilder = new BodyBuilder { HtmlBody = body };
        email.Body = bodyBuilder.ToMessageBody();

        using var client = new SmtpClient();
        
        // Timeout de 10 secondes pour éviter de bloquer indéfiniment
        client.Timeout = 10000;

        _logger.LogInformation("Connexion au serveur SMTP {Host}:{Port}...", host, port);
        
        var socketOption = port == 465 ? SecureSocketOptions.SslOnConnect : SecureSocketOptions.StartTls;
        await client.ConnectAsync(host, port, socketOption);
        
        _logger.LogInformation("Authentification SMTP pour {Username}...", username);
        await client.AuthenticateAsync(username, password);

        _logger.LogInformation("Envoi de l'email à {ToEmail}...", toEmail);
        await client.SendAsync(email);
        await client.DisconnectAsync(true);

        _logger.LogInformation("Email envoyé avec succès à {ToEmail}", toEmail);
    }
}
