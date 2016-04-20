class SetupComponents
  constructor: (board, components) ->
    

  digitalWrite: (opts) =>
    self.board.pinMode(opts.pin, self.board.MODES.OUTPUT)
    self.bot.names.push(opts.name)

  digitalRead: (opts) =>
    self.board.pinMode(opts.pin, five.Pin.INPUT)
    self.board.digitalRead opts.pin, (value) ->
      if _.has(self.bot.component, opts.name)
        self.bot.read[opts.name] = value


module.exports = SetupComponents
