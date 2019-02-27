import { BaseEntity } from './../../shared';

export class AppResource implements BaseEntity {
    constructor(
        public id?: number,
        public code?: string,
        public name?: string,
        public type?: string,
        public description?: string,
        public seqNo?: number,
        public depth?: number,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
        public parent?: BaseEntity,
    ) {
    }
}
