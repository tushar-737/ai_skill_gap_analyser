// Inline error banner used for both backend errors and
// form validation. role="alert" announces the message to
// screen readers as soon as it appears.

export default function ErrorBanner({ message }) {
    if (!message) return null;

    return (
        <div
            className="error-message"
            role="alert"
        >
            {message}
        </div>
    );
}
