/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam;

use namespace HTL\SGMLStreamInterfaces;

final class ToStringsConsumer implements SGMLStreamInterfaces\Consumer {
  private vec<string> $strings = vec[];
  private bool $isComplete = false;

  public async function consumeAsync(string $bytes)[defaults]: Awaitable<void> {
    $this->strings[] = $bytes;
  }

  public async function receiveWaitNotificationAsync(
  )[defaults]: Awaitable<void> {}
  public async function flushAsync()[defaults]: Awaitable<void> {}
  public async function theDocumentIsCompleteAsync(
  )[defaults]: Awaitable<void> {
    $this->isComplete = true;
  }

  public function toStrings()[]: vec<string> {
    invariant(
      $this->isComplete,
      'The Streamable has not yet been fully consumed. '.
      'The document is not complete yet.',
    );
    return $this->strings;
  }
}
