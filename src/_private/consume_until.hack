/** sgml-stream-exam is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStreamExam\_Private;

use namespace HH\Lib\{Math, Str};
use namespace HTL\SGMLStreamExam;

function consume_until_space_exclusive(string $bytes)[]: (string, string) {
  $space = Str\search($bytes, ' ');
  if ($space is null) {
    return tuple($bytes, '');
  }

  return tuple(Str\slice($bytes, 0, $space), Str\slice($bytes, $space + 1));
}

function consume_until_equals_or_space_inclusive(
  string $bytes,
)[]: (string, string, string) {
  $space = Str\search($bytes, ' ');
  $equals = Str\search($bytes, '=');

  if ($space is null && $equals is null) {
    return tuple($bytes, ' ', '');
  }

  $offset = Math\minva($space ?? Math\INT64_MAX, $equals ?? Math\INT64_MAX);

  return tuple(
    Str\slice($bytes, 0, $offset),
    $bytes[$offset],
    Str\slice($bytes, $offset + 1),
  );
}

function consume_attribute_value(string $bytes)[defaults]: (string, string) {
  if ($bytes[0] !== '"') {
    throw new SGMLStreamExam\UnexpectedHTMLException(
      Str\format('Expected double quoted attribute, got: %s', $bytes),
    );
  }
  $end = Str\search($bytes, '"', 1);

  if ($end is null) {
    throw new SGMLStreamExam\UnexpectedHTMLException(
      Str\format('Expected double quoted attribute, got: %s', $bytes),
    );
  }

  return tuple(
    \htmlspecialchars_decode(Str\slice($bytes, 1, $end - 1)),
    Str\slice($bytes, $end + 1),
  );
}
