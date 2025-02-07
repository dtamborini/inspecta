part of 'open_ticket_page.dart';

/// Login form class provide all required field to login
class _OpenTicketView extends StatefulWidget {
  /// Build [_OpenTicketView] instance
  const _OpenTicketView({
    required this.closePage,
  });

  final bool closePage;

  @override
  State<_OpenTicketView> createState() => _OpenTicketViewState();
}

class _OpenTicketViewState extends State<_OpenTicketView> {
  final _controllerKeyboard = TextEditingController();

  final blocKeyboard = VirtualKeyboardBloc();

  final blocAssetReference = SimpleTextBloc();
  final blocName = SimpleTextBloc();
  final blocDesc = SimpleTextBloc();
  final blocPriority = SimpleTextBloc();

  final focusKeyboard = FocusNode();

  @override
  void dispose() {
    super.dispose();
    focusKeyboard.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late SimpleTextBloc activeBloc;
    return OMDKSimplePage(
      withBottomBar: false,
      withDrawer: false,
      leading: FilledButton(
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.red),
        ),
        focusNode: FocusNode(),
        onPressed: () {
          context.read<AuthRepo>().logOut();
          if (widget.closePage && kIsWeb) {
            return web.window.close();
          }
        },
        child: Text(
          context.l.alert_btn_cancel,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Colors.white),
        ),
      ),
      bodyPage: BlocListener<OpenTicketBloc, OpenTicketState>(
        listenWhen: (previous, current) =>
            previous.loadingStatus != current.loadingStatus ||
            previous.activeFieldBloc != current.activeFieldBloc,
        listener: (context, state) {
          if (state.loadingStatus == LoadingStatus.done) {
            if (widget.closePage && kIsWeb) {
              return web.window.close();
            }
            OMDKAlert.show(
              context,
              OMDKAlert(
                title: AppLocalizations.of(context)!.alert_title_done,
                type: AlertType.success,
                message: Text(
                  '${state.failureText}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                confirm: AppLocalizations.of(context)!.alert_btn_ok,
                onConfirm: () => context.read<AuthRepo>().logOut(),
              ),
            );
          }
          if (state.loadingStatus == LoadingStatus.failure) {
            OMDKAlert.show(
              context,
              OMDKAlert(
                title: AppLocalizations.of(context)!.alert_title_warning,
                type: AlertType.warning,
                message: Text(
                  '${state.failureText}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                confirm: AppLocalizations.of(context)!.alert_btn_ok,
                onConfirm: () =>
                    context.read<OpenTicketBloc>().add(ResetWarning()),
              ),
            );
          }
          if (state.activeFieldBloc != null) {
            activeBloc = state.activeFieldBloc!;
          }
        },
        child: (context.read<OpenTicketBloc>().state.loadingStatus !=
                LoadingStatus.fatal)
            ? Padding(
                padding: const EdgeInsets.only(top: 20, left: 14, right: 14),
                child: Column(
                  children: [
                    Expanded(
                      child: (ResponsiveWidget.isSmallScreen(context))
                          ? singleColumnLayout(context)
                          : Center(
                              child: twoColumnLayout(context, blocKeyboard),
                            ),
                    ),
                    CustomVirtualKeyboard(
                      bloc: blocKeyboard,
                      focusNode: focusKeyboard,
                      controller: _controllerKeyboard,
                      onKeyPress: (key) => _onKeyPress(
                        context,
                        key,
                        activeBloc,
                        blocKeyboard,
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: OMDKAlert(
                  title: AppLocalizations.of(context)!.alert_title_fatal_error,
                  message: Text(
                    '${context.read<OpenTicketBloc>().state.failureText}',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  type: AlertType.fatalError,
                  confirm: AppLocalizations.of(context)!.alert_btn_ok,
                  onConfirm: () {},
                ),
              ),
      ),
    );
  }

  void _onKeyPress(
    BuildContext context,
    VirtualKeyboardKey key,
    SimpleTextBloc bloc,
    VirtualKeyboardBloc keyboardBloc,
  ) {
    final text = bloc.state.text ?? '';
    final arrayText =
        List<String>.generate(text.length, (index) => text[index]);

    if (key.keyType == VirtualKeyboardKeyType.String) {
      arrayText.insert(
        bloc.state.cursorPosition,
        (keyboardBloc.state.isShiftEnabled
            ? key.capsText.toString()
            : key.text.toString()),
      );
    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Backspace:
          if (text.isEmpty) return;
          arrayText.removeAt(bloc.state.cursorPosition - 1);
          return bloc.add(
            TextChanged(arrayText.join(), bloc.state.cursorPosition - 1),
          );
        case VirtualKeyboardKeyAction.Return:
          arrayText.insert(
            bloc.state.cursorPosition,
            '\n',
          );
        case VirtualKeyboardKeyAction.Space:
          arrayText.insert(
            bloc.state.cursorPosition,
            key.text.toString(),
          );
        case VirtualKeyboardKeyAction.Shift:
          return keyboardBloc.add(ChangeShift());
        case VirtualKeyboardKeyAction.SwithLanguage:
        case null:
          break;
      }
    }
    bloc.add(TextChanged(arrayText.join(), bloc.state.cursorPosition + 1));
  }

  Widget twoColumnLayout(
    BuildContext context,
    VirtualKeyboardBloc keyboardBloc,
  ) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: ListView(
            children: [
              const _AssetReference(),
              _TicketNameInput(keyboardBloc: blocKeyboard),
              _TicketDescInput(keyboardBloc: blocKeyboard),
              const Space.vertical(10),
              const _TicketPriorityInput(),
              const _TicketSchemaInput(),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _TicketStepList(keyboardBloc: blocKeyboard),
          ),
        ),
      ],
    );
  }

  Widget singleColumnLayout(BuildContext context) => ListView(
        children: [
          const _AssetReference(),
          _TicketNameInput(keyboardBloc: blocKeyboard),
          _TicketDescInput(keyboardBloc: blocKeyboard),
          const Space.vertical(10),
          const _TicketPriorityInput(),
          const _TicketSchemaInput(),
          _TicketStepList(keyboardBloc: blocKeyboard),
        ],
      );
}

class _AssetReference extends StatelessWidget {
  /// Create [_AssetReference] instance
  const _AssetReference();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenTicketBloc, OpenTicketState>(
      buildWhen: (previous, current) => previous.jMainNode != current.jMainNode,
      builder: (context, state) => (state.jMainNode != null)
          ? FieldString(
              key: const Key('assetReference_textField'),
              isEnabled: false,
              onChanged: (text) {},
              labelText: context.l.ticket_label_asset_reference,
              initialText: state.jMainNode?.name,
              focusNode: FocusNode(),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _TicketNameInput extends StatelessWidget {
  /// Create [_TicketNameInput] instance
  const _TicketNameInput({required this.keyboardBloc});

  final VirtualKeyboardBloc keyboardBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenTicketBloc, OpenTicketState>(
      builder: (context, state) => FieldString(
        key: const Key('ticketNameInput_textField'),
        initialText: state.ticketName,
        onChanged: (text) =>
            context.read<OpenTicketBloc>().add(TicketNameChanged(text)),
        labelText: context.l.ticket_label_name,
        keyboardBloc: keyboardBloc,
        onTapBloc: (bloc) =>
            context.read<OpenTicketBloc>().add(TicketEditing(bloc: bloc)),
        focusNode: FocusNode(),
      ),
    );
  }
}

class _TicketDescInput extends StatelessWidget {
  /// Create [_TicketDescInput] instance
  const _TicketDescInput({required this.keyboardBloc});

  final VirtualKeyboardBloc keyboardBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenTicketBloc, OpenTicketState>(
      builder: (context, state) => FieldString(
        key: const Key('ticketDescInput_textField'),
        initialText: state.ticketDescription,
        onChanged: (text) =>
            context.read<OpenTicketBloc>().add(TicketDescChanged(text)),
        labelText: context.l.ticket_label_description,
        keyboardBloc: keyboardBloc,
        onTapBloc: (bloc) =>
            context.read<OpenTicketBloc>().add(TicketEditing(bloc: bloc)),
        focusNode: FocusNode(),
      ),
    );
  }
}

class _TicketPriorityInput extends StatelessWidget {
  /// Create [_TicketPriorityInput] instance
  const _TicketPriorityInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenTicketBloc, OpenTicketState>(
      buildWhen: (previous, current) =>
          previous.ticketPriority != current.ticketPriority,
      builder: (context, state) => PriorityButtons(
        key: const Key('ticketPriorityInput_textField'),
        onSelectedPriority: (priorityCode) => context
            .read<OpenTicketBloc>()
            .add(TicketPriorityChanged(priorityCode)),
        labelText: context.l.ticket_label_priority,
        indexSelectedRadio: state.ticketPriority,
        focusNode: FocusNode(),
      ),
    );
  }
}

class _TicketSchemaInput extends StatelessWidget {
  /// Create [_TicketSchemaInput] instance
  const _TicketSchemaInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenTicketBloc, OpenTicketState>(
      buildWhen: (previous, current) =>
          previous.selectedSchemaIndex != current.selectedSchemaIndex ||
          previous.schemas != current.schemas,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      context.l.ticket_label_typology.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: state.schemas.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ColoredBox(
                      color: index == state.selectedSchemaIndex
                          ? Colors.white
                          : Theme.of(context).scaffoldBackgroundColor,
                      child: ListTile(
                        selected: index == state.selectedSchemaIndex,
                        selectedColor:
                            Theme.of(context).inputDecorationTheme.fillColor,
                        onTap: () => context.read<OpenTicketBloc>().add(
                              SelectedSchemaChanged(
                                schemaIndex: index,
                                schemaMappingGuid:
                                    state.schemas[index].mapping.guid!,
                                schemaGuid: state.schemas[index].guid,
                              ),
                            ),
                        title: Text(
                          '${state.schemas[index].name}',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: index == state.selectedSchemaIndex
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                fontWeight: index == state.selectedSchemaIndex
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TicketStepList extends StatelessWidget {
  /// Create [_TicketStepList] instance
  const _TicketStepList({
    this.keyboardBloc,
  });

  final VirtualKeyboardBloc? keyboardBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenTicketBloc, OpenTicketState>(
      buildWhen: (previous, current) =>
          previous.loadingStatus != current.loadingStatus,
      builder: (context, state) {
        return (state.ticketEntity != null)
            ? Align(
                alignment: Alignment.topCenter,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: state.ticketEntity!.stepsList.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= state.ticketEntity!.stepsList.length) {
                      return submitTicket(context: context);
                    }
                    return ExpansionTile(
                      //initiallyExpanded: index == 0, not expand automatically
                      title: Text(
                        '${context.localizeLabel(state.ticketEntity!.stepsList[index].title)}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      children: buildFieldList(
                        context: context,
                        stepEntity: state.ticketEntity!.stepsList[index],
                        schemaMapping: state.schemaMapping!,
                        keyboardBloc: keyboardBloc,
                      ),
                    );
                  },
                ),
              )
            : Center(
                child: Text(
                  AppLocalizations.of(context)!.ticket_hint_select_schema,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              );
      },
    );
  }

  List<Widget> buildFieldList({
    required BuildContext context,
    required JStepEntity stepEntity,
    required MappingVersion schemaMapping,
    VirtualKeyboardBloc? keyboardBloc,
  }) {
    // Widget list to show
    final fieldWidgets = <Widget>[];

    final stepMapping = schemaMapping.data.defStepsList?.firstWhere(
      (stepMapping) => stepMapping.hash == stepEntity.stepMappingHash,
    );

    for (final jFieldMapping in stepMapping!.fieldsList!) {
      final jFieldEntity = stepEntity.fieldsList?.firstWhereOrNull(
        (JFieldEntity jFieldEntity) =>
            jFieldEntity.mappingHash == jFieldMapping.hash,
      );
      if (jFieldEntity!.operations!.design!.values!.contains('R')) {
        fieldWidgets.add(
          buildField(
            context: context,
            jFieldMapping: jFieldMapping,
            jFieldEntity: jFieldEntity,
            stepGuid: stepEntity.guid!,
            keyboardBloc: keyboardBloc,
          ),
        );
      }
    }
    return fieldWidgets;
  }

  Widget buildField({
    required BuildContext context,
    required JFieldMapping jFieldMapping,
    required String stepGuid,
    JFieldEntity? jFieldEntity,
    VirtualKeyboardBloc? keyboardBloc,
  }) {
    switch (jFieldMapping.type) {
      case FieldType.String:
        switch (jFieldMapping.collectionType) {
          case CollectionType.List:
            return FieldPoolList(
              labelText: '${context.localizeLabel(jFieldMapping.title)}',
              listItem: jFieldMapping.poolListSettings!.value!,
              isEnabled: jFieldMapping.operations!.design.checkU,
              onChanged: (String? s) => context.read<OpenTicketBloc>().add(
                    FieldChanged(
                      stepGuid: stepGuid,
                      fieldMapping: jFieldMapping,
                      fieldGuid: jFieldEntity!.guid!,
                      fieldValue: <String>[s!],
                    ),
                  ),
            );
          case CollectionType.Single:
            if (jFieldMapping.poolListSettings?.value != null) {
              return FieldPoolList(
                selectedItem: jFieldEntity?.value?.stringsList?.first,
                labelText: '${context.localizeLabel(jFieldMapping.title)}',
                listItem: jFieldMapping.poolListSettings!.value!,
                isEnabled: jFieldMapping.operations!.design.checkU,
                onChanged: (String? s) => context.read<OpenTicketBloc>().add(
                      FieldChanged(
                        stepGuid: stepGuid,
                        fieldMapping: jFieldMapping,
                        fieldGuid: jFieldEntity!.guid!,
                        fieldValue: <String>[s!],
                      ),
                    ),
              );
            } else if (jFieldMapping.poolListSettings?.multiSelect ?? false) {
              return FieldMultiPoolList(
                labelText: '${context.localizeLabel(jFieldMapping.title)}',
                isEnabled:
                    jFieldEntity!.operations!.design!.values!.contains('U'),
                listItem: jFieldMapping.poolListSettings!.value!,
                focusNode: FocusNode(),
                onSelected: (List<PoolItem?> selectedItems) {},
              );
            } else {
              return FieldString(
                labelText: '${context.localizeLabel(jFieldMapping.title)}',
                initialText: jFieldEntity?.value?.stringValue,
                keyboardBloc: keyboardBloc,
                onTapBloc: (bloc) => context
                    .read<OpenTicketBloc>()
                    .add(TicketEditing(bloc: bloc)),
                isEnabled: jFieldMapping.operations!.design.checkU,
                focusNode: FocusNode(),
                onChanged: (String? s) => context.read<OpenTicketBloc>().add(
                      FieldChanged(
                        stepGuid: stepGuid,
                        fieldMapping: jFieldMapping,
                        fieldGuid: jFieldEntity!.guid!,
                        fieldValue: s,
                      ),
                    ),
              );
            }
          case CollectionType.unknown:
            return const Stack();
        }
      case FieldType.Image:
        if (jFieldEntity?.value == null) return const Stack();
        // return FieldImage(
        //   labelText: '${(jFieldMapping.title?.singleWhereOrNull(
        //         (element) =>
        //     element.culture?.contains(
        //       Localizations.localeOf(context).languageCode,
        //     ) ??
        //         false,
        //   ) ?? jFieldMapping.title?[0])?.value}',
        //   imageGuid: jFieldEntity?.value?.imagesList?.first,
        // );
        return FieldSliderImages(
          labelText: '${context.localizeLabel(jFieldMapping.title)}',
          imageList: jFieldEntity?.value?.imagesList,
        );
      case FieldType.Double:
        return FieldDouble(
          labelText: '${context.localizeLabel(jFieldMapping.title)}',
          keyboardBloc: keyboardBloc,
          onTapBloc: (bloc) =>
              context.read<OpenTicketBloc>().add(TicketEditing(bloc: bloc)),
          focusNode: FocusNode(),
          isEnabled: jFieldMapping.operations!.design.checkU,
          onChanged: (double? d) => context.read<OpenTicketBloc>().add(
                FieldChanged(
                  stepGuid: stepGuid,
                  fieldMapping: jFieldMapping,
                  fieldGuid: jFieldEntity!.guid!,
                  fieldValue: d,
                ),
              ),
        );
      case FieldType.Int32:
        return FieldInt(
          labelText: '${context.localizeLabel(jFieldMapping.title)}',
          focusNode: FocusNode(),
          keyboardBloc: keyboardBloc,
          isEnabled: jFieldMapping.operations!.design.checkU,
          onTapBloc: (bloc) =>
              context.read<OpenTicketBloc>().add(TicketEditing(bloc: bloc)),
          onChanged: (int? i) => context.read<OpenTicketBloc>().add(
                FieldChanged(
                  stepGuid: stepGuid,
                  fieldMapping: jFieldMapping,
                  fieldGuid: jFieldEntity!.guid!,
                  fieldValue: i,
                ),
              ),
        );
      case FieldType.Bool:
        return FieldBool(
          labelText: '${context.localizeLabel(jFieldMapping.title)}',
          focusNode: FocusNode(),
          isEnabled: jFieldMapping.operations!.design.checkU,
          onChanged: (bool? b) => context.read<OpenTicketBloc>().add(
                FieldChanged(
                  stepGuid: stepGuid,
                  fieldMapping: jFieldMapping,
                  fieldGuid: jFieldEntity!.guid!,
                  fieldValue: b,
                ),
              ),
        );
      case FieldType.DateTime:
        return FieldDateTime(
          labelText: '${context.localizeLabel(jFieldMapping.title)}',
          isActionEnabled: jFieldMapping.operations!.design.checkU,
          initialDate: jFieldEntity?.value?.dateTimeValue,
          onChanged: (date) => context.read<OpenTicketBloc>().add(
                FieldChanged(
                  stepGuid: stepGuid,
                  fieldMapping: jFieldMapping,
                  fieldGuid: jFieldEntity!.guid!,
                  fieldValue: date,
                ),
              ),
          focusNode: FocusNode(),
        );
      case FieldType.File:
      case FieldType.StepResult:
      case FieldType.InternalStep:
      case FieldType.unknown:
      case FieldType.LinkToEntities:
        return const Stack();
    }
  }

  Widget submitTicket({
    required BuildContext context,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              focusNode: FocusNode(),
              onPressed: () =>
                  context.read<OpenTicketBloc>().add(SubmitTicket()),
              child: Text(context.l.ticket_btn_submit),
            ),
          ),
        ],
      );
}
